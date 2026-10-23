using System;
using System.IO;
using System.Linq;
using Asysco.Amt.AmtSharedDataModel.Support;
using Asysco.Amt.Libs.Database;
using Asysco.Amt.Libs.Settings;
using Asysco.Amt.Libs.Support;
using Asysco.Amt.Libs.SystemTables;

namespace MockSystemTool {

  // Commands: probe (read-only) | seed (adds the mock application records if missing) | run --dll <file> [--type <full name>]
  // Always: --ini <path to the mock Sys.ini>. Refuses to run unless the Sys.ini names the mock database.
  internal static class Program {

    private const String MockDbName = "AMT_MOCKSYS";
    private static String AppName = "CFHCOPYASCII";
    private const String AppBase = @"E:\AMT_Work\Apps\";
    private const String MockRoot = @"E:\AMT_Work\MockTest\";

    private static Int32 Main (String[] args) {
      String cmd = args.FirstOrDefault(a => !a.StartsWith("--", StringComparison.Ordinal)) ?? "probe";
      Int32 iniAt = Array.IndexOf(args, "--ini");
      if (Arg(args, "--app") != null) { AppName = Arg(args, "--app"); }
      String ini = (iniAt >= 0 && iniAt + 1 < args.Length) ? args[iniAt + 1] : Path.Combine(AppContext.BaseDirectory, "Sys.ini");
      if (!File.Exists(ini)) { Console.WriteLine("Sys.ini not found: " + ini); return 2; }

      AmtConfiguration cfg = new AmtConfiguration("MockSystemTool");
      cfg.ReadSysIniFile(ini);
      AmtSettingsDatabase s = cfg.SysDbSettings;
      Console.WriteLine("Sys.ini : " + ini);
      Console.WriteLine("Server  : " + s.DbsServer + "   Database: " + s.DbsName + "   User: " + s.User);
      if (!String.Equals(s.DbsName, MockDbName, StringComparison.OrdinalIgnoreCase)) {
        Console.WriteLine("REFUSED: this tool only works on " + MockDbName + ".");
        return 3;
      }

      if (cmd == "run") { return Run(args, ini); }

      using (AmtDatabase db = new AmtDatabase(s.DbType)) {
        db.Server = s.DbsServer;
        db.DbName = s.DbsName;
        db.UserName = s.User;
        db.Password = s.Password;
        db.IntegratedSecurity = s.IntegratedSecurity;
        db.Schema = s.Schema;
        db.UseSSLConnection = s.UseDbSSLConnection;
        db.Open();
        switch (cmd) {
          case "probe": Probe(db); return 0;
          case "seed": Seed(db); Probe(db); return 0;
          case "set-app-kind": SetAppKind(db, Arg(args, "--kind")); Probe(db); return 0;
          case "set-app-base": SetAppBase(db, Arg(args, "--app-base")); Probe(db); return 0;
          case "seed-app": SeedApplication(db); Probe(db); return 0;
          case "seed-fc": SeedFileController(db); Probe(db); return 0;
          case "seed-db": SeedDatabase(db, s, Arg(args, "--db-name") ?? s.DbsName); Probe(db); return 0;
          default: Console.WriteLine("Unknown command " + cmd); return 2;
        }
      }
    }

    private static String Arg (String[] args, String name) {
      Int32 at = Array.IndexOf(args, name);
      return (at >= 0 && at + 1 < args.Length) ? args[at + 1] : null;
    }

    // Starts a generated program through its public static Int32 Main(String[]), as the AMT batch host does.
    private static Int32 Run (String[] args, String ini) {
      String dll = Arg(args, "--dll");
      if (String.IsNullOrEmpty(dll)) { Console.WriteLine("run needs --dll <program dll>"); return 2; }
      System.Reflection.Assembly asm = System.Reflection.Assembly.LoadFrom(Path.GetFullPath(dll));
      String typeName = Arg(args, "--type");
      Type program = asm.GetExportedTypes().FirstOrDefault(t =>
        (typeName == null || t.FullName == typeName) && t.GetMethod("Main", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static, null, new[] { typeof(String[]) }, null) != null);
      if (program == null) { Console.WriteLine("No public type with static Main(String[]) in " + dll); return 2; }
      Console.WriteLine("Running " + program.FullName + " in application " + AppName);
      Object result = program.GetMethod("Main", new[] { typeof(String[]) }).Invoke(null, new Object[] { new[] { "/I:" + ini, "/APP:" + AppName, "/TESTRUN" } });
      Console.WriteLine("Program exit code: " + result);
      return Convert.ToInt32(result);
    }

    private static void Probe (AmtDatabase db) {
      Console.WriteLine("--- system records");
      using (AmtSysBasepath bp = new AmtSysBasepath(db)) {
        for (Boolean ok = bp.SelectAll(); !bp.Eof; bp.Next()) { Console.WriteLine("basepath  " + bp.BasepathId + "  " + bp.Description + "  extract=" + bp.ExtractPath); }
      }
      using (AmtSysLogging lg = new AmtSysLogging(db)) {
        for (Boolean ok = lg.SelectAll(); !lg.Eof; lg.Next()) { Console.WriteLine("logging   " + lg.LoggingId); }
      }
      using (AmtSysRuntimeBehaviour rt = new AmtSysRuntimeBehaviour(db)) {
        for (Boolean ok = rt.SelectAll(); !rt.Eof; rt.Next()) { Console.WriteLine("rtbehave  " + rt.RtBehaviourId + "  " + rt.Description); }
      }
      using (AmtSysConfig cf = new AmtSysConfig(db)) {
        for (Boolean ok = cf.SelectAll(); !cf.Eof; cf.Next()) { Console.WriteLine("config    " + cf.ConfigId + "  basepath=" + cf.BasepathId + " logging=" + cf.LoggingId + " rt=" + cf.RtBehaviourID); }
      }
      using (AmtSysApplication ap = new AmtSysApplication(db)) {
        for (Boolean ok = ap.SelectAll(); !ap.Eof; ap.Next()) { Console.WriteLine("app       " + ap.AppId + "  " + ap.AppName + "  base=" + ap.AppBasepath + " config=" + ap.ConfigId + " kind=" + ap.ApplicationKind); }
      }
    }

    private static void SetAppKind (AmtDatabase db, String kind) {
      if (String.IsNullOrEmpty(kind)) { throw new ArgumentException("set-app-kind needs --kind <LionOS2200|CobolOS2200|...>"); }
      using (AmtSysApplication ap = new AmtSysApplication(db)) {
        if (!ap.SelectByAppName(AppName)) { throw new InvalidOperationException("Application " + AppName + " not found."); }
        ap.ApplicationKind = (AmtApplicationKind)Enum.Parse(typeof(AmtApplicationKind), kind);
        ap.Change();
        Console.WriteLine("Application " + AppName + " kind set to " + ap.ApplicationKind);
      }
    }

    private static void SetAppBase (AmtDatabase db, String appBase) {
      if (String.IsNullOrEmpty(appBase)) { throw new ArgumentException("set-app-base needs --app-base <folder>"); }
      using (AmtSysApplication ap = new AmtSysApplication(db)) {
        if (!ap.SelectByAppName(AppName)) { throw new InvalidOperationException("Application " + AppName + " not found."); }
        ap.AppBasepath = appBase.EndsWith("\\") ? appBase : appBase + "\\";
        ap.Change();
        Console.WriteLine("Application " + AppName + " base path set to " + ap.AppBasepath);
      }
    }

    // Another application on the first application's configuration and database definition (same AMT_MOCKAPP).
    private static void SeedApplication (AmtDatabase db) {
      using (AmtSysApplication first = new AmtSysApplication(db))
      using (AmtSysApplication ap = new AmtSysApplication(db)) {
        if (ap.SelectByAppName(AppName)) { Console.WriteLine("Application " + AppName + " already exists (id " + ap.AppId + ")."); return; }
        if (!first.SelectByAppName("CFHCOPYASCII")) { throw new InvalidOperationException("Seed CFHCOPYASCII first."); }
        using (AmtSysApplication add = new AmtSysApplication(db)) {
          add.AppName = AppName;
          add.ApplicationType = AmtApplicationType.User;
          add.ConfigId = first.ConfigId;
          add.DatabaseId = first.DatabaseId;
          add.AppBasepath = AppBase;
          add.Description = "Mock application for the SSG-4 mock run";
          add.ApplicationKind = AmtApplicationKind.LionOS2200;
          add.Add();
          Console.WriteLine("Registered application " + AppName + " (config " + first.ConfigId + ", database " + first.DatabaseId + ").");
        }
      }
    }

    private const String FcName = "MockFileController";
    private const Int32 FcPort = 18132;

    private static void SeedFileController (AmtDatabase db) {
      String host = AmtOS.GetHostName();
      using (AmtSysFileController fc = new AmtSysFileController(db)) {
        if (fc.SelectByServiceName(FcName, host, AmtContainerType.None)) { Console.WriteLine("File controller " + FcName + " already registered (id " + fc.ControllerId + ")."); return; }
        fc.ServiceName = FcName;
        fc.DisplayName = "Mock file controller";
        fc.ServerName = host;
        fc.ContainerType = AmtContainerType.None;
        fc.Basepath = MockRoot;
        fc.LogPath = MockRoot + @"Logs\";
        fc.GrpcAddress = "localhost";
        fc.GrpcPort = FcPort;
        fc.Spare = false;
        fc.ForcedTimeout = 3600;
        fc.FormsForcedTimeout = 3600;
        fc.BatchRunningCheckInterval = 10;
        fc.ResetSecurityAfterMove = false;
        fc.BatchControllerId = 0;
        fc.Add();
        Console.WriteLine("Registered file controller " + FcName + " on " + host + " port " + FcPort + " (id " + fc.ControllerId + ").");
      }
    }

    private static void SeedDatabase (AmtDatabase db, AmtSettingsDatabase s, String dbName) {
      // The application database is a separate database on the same server, reached with the same login.
      db.StartTransaction();
      try {
        Int32 databaseId;
        using (AmtSysApplication ap = new AmtSysApplication(db))
        using (AmtSysDatabaseSetting ds = new AmtSysDatabaseSetting(db)) {
          if (!ap.SelectByAppName(AppName)) { throw new InvalidOperationException("Run seed first: application " + AppName + " not found."); }
          Boolean exists = ap.DatabaseId > 0 && ds.Select(ap.DatabaseId);
          ds.DatabaseServer = s.DbsServer;
          ds.DatabaseName = dbName;
          ds.DbType = s.DbType;
          ds.DatabaseKind = AmtDatabaseKind.Internal;
          ds.Schema = s.Schema;
          ds.User = s.User;
          ds.Password = s.Password;
          ds.UserBL = s.User;
          ds.PasswordBL = s.Password;
          ds.UserRtQuery = s.User;
          ds.PasswordRtQuery = s.Password;
          ds.IntegratedSecurity = s.IntegratedSecurity;
          ds.IntegratedSecurityBL = s.IntegratedSecurity;
          ds.IntegratedSecurityRtQuery = s.IntegratedSecurity;
          ds.UseSSLConnection = s.UseDbSSLConnection;
          if (exists) { ds.Change(); } else { ds.Add(); }
          databaseId = ds.DatabaseId;
          if (ap.DatabaseId != databaseId) { ap.DatabaseId = databaseId; ap.Change(); }
        }
        db.Commit();
        Console.WriteLine("Database definition " + databaseId + " (" + dbName + ") linked to " + AppName);
      } catch {
        db.Rollback();
        throw;
      }
    }

    private static void Seed (AmtDatabase db) {
      using (AmtSysApplication probe = new AmtSysApplication(db)) {
        if (probe.SelectByAppName(AppName)) { Console.WriteLine("Application " + AppName + " already exists (id " + probe.AppId + "). Nothing added."); return; }
      }
      foreach (String d in new[] { "Extracts", "Scripts", "Prints", "ListBox", "Calls", "Help", "Logs", "Images", "Uploads" }) {
        Directory.CreateDirectory(Path.Combine(MockRoot, d));
      }
      db.StartTransaction();
      try {
        Int32 basepathId, loggingId, rtId, configId;
        using (AmtSysBasepath bp = new AmtSysBasepath(db)) {
          bp.Description = "MOCK";
          bp.ExtractPath = MockRoot + @"Extracts\";
          bp.ScriptPath = MockRoot + @"Scripts\";
          bp.PrintPath = MockRoot + @"Prints\";
          bp.ListBoxPath = MockRoot + @"ListBox\";
          bp.CallPath = MockRoot + @"Calls\";
          bp.HelpPath = MockRoot + @"Help\";
          bp.LogPath = MockRoot + @"Logs\";
          bp.ImagePath = MockRoot + @"Images\";
          bp.UploadPath = MockRoot + @"Uploads\";
          bp.Add();
          basepathId = bp.BasepathId;
        }
        using (AmtSysLogging lg = new AmtSysLogging(db)) {
          lg.Add();
          loggingId = lg.LoggingId;
        }
        using (AmtSysRuntimeBehaviour rt = new AmtSysRuntimeBehaviour(db)) {
          rt.Description = "MOCK";
          rt.Add();
          rtId = rt.RtBehaviourId;
        }
        using (AmtSysConfig cf = new AmtSysConfig(db)) {
          cf.BasepathId = basepathId;
          cf.LoggingId = loggingId;
          cf.RtBehaviourID = rtId;
          cf.Add();
          configId = cf.ConfigId;
        }
        using (AmtSysApplication ap = new AmtSysApplication(db)) {
          ap.AppName = AppName;
          ap.ApplicationType = AmtApplicationType.User;
          ap.ConfigId = configId;
          ap.AppBasepath = AppBase;
          ap.Description = "Mock application for the SSG-4 mock run";
          ap.ApplicationKind = AmtApplicationKind.LionOS2200;
          ap.Add();
        }
        db.Commit();
        Console.WriteLine("Seeded: basepath " + basepathId + ", logging " + loggingId + ", rtbehaviour " + rtId + ", config " + configId + ", application " + AppName);
      } catch {
        db.Rollback();
        throw;
      }
    }
  }
}
