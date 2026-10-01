# Converter info added by Asysco
# Generation date & time: 16-10-2017  15:00:37
#
# Define options for the @Chg statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum ChgOptions {
    None = 0x00000000,
    E = 0x00000001,
    F = 0x00000002,
    K = 0x00000004,
    M = 0x00000008,
    N = 0x00000010,
    P = 0x00000020,
    Q = 0x00000040,
    T = 0x00000080,
    V = 0x00000100,
    W = 0x00000200,
    Z = 0x00000400
  }
"@

# Define options for the @Ers statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum ErsOptions {
    None = 0x00000000,
    I = 0x00000001,
    N = 0x00000002,
    G = 0x00000004,
    Z = 0x00000008
  }
"@

# Define options for the @Hdg statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum HdgOptions {
    None = 0x00000000,
    N = 0x00000001,
    P = 0x00000002,
    X = 0x00000004
  }
"@

# Define options for the @Mark statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum MarkOptions {
    None = 0x00000000,
    E = 0x00000001,
    W = 0x00000002
  }
"@

# Define options for the @Move statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum MoveOptions {
    None = 0x00000000,
    B = 0x00000001
  }
"@

# Define options for the @Pack statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum PackOptions {
    None = 0x00000000,
    A = 0x00000001,
    C = 0x00000002,
    D = 0x00000004,
    I = 0x00000008,
    L = 0x00000010,
    M = 0x00000020,
    N = 0x00000040,
    O = 0x00000080,
    P = 0x00000100,
    R = 0x00000200,
    S = 0x00000400,
    Y = 0x00000800,
    Z = 0x00001000
  }
"@

# Define options for the @PerfEv statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum PerfEvOptions {
    None = 0x00000000,
    A = 0x00000001,
    O = 0x00000002,
    P = 0x00000004,
    S = 0x00000008
  }
"@

# Define options for the @Rewind statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum RewindOptions {
    None = 0x00000000,
    C = 0x00000001,
    I = 0x00000002
  }
"@

# Define options for the @Add statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum AddOptions {
    None = 0x00000000,
    D = 0x00000001,
    E = 0x00000002,
    F = 0x00000004,
    L = 0x00000008,
    P = 0x00000010,
    R = 0x00000020
  }
"@

# Define options for the @Asg statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum AsgOptions {
    None = 0x00000000,
    I = 0x00000001,
    Z = 0x00000002,
    B = 0x00000004,
    C = 0x00000008,
    G = 0x00000010,
    P = 0x00000020,
    R = 0x00000040,
    S = 0x00000080,
    U = 0x00000100,
    V = 0x00000200,
    W = 0x00000400,
    A = 0x00000800,
    D = 0x00001000,
    E = 0x00002000,
    K = 0x00004000,
    M = 0x00008000,
    Q = 0x00010000,
    T = 0x00020000,
    X = 0x00040000,
    Y = 0x00080000,
    F = 0x00100000,
    J = 0x00200000
  }
"@

# Define options for the @BrkPt statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum BrkPtOptions {
    None = 0x00000000,
    L = 0x00000001,
    E = 0x00000002
  }
"@

# Define options for the @Cat statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum CatOptions {
    None = 0x00000000,
    B = 0x00000001,
    G = 0x00000002,
    P = 0x00000004,
    R = 0x00000008,
    S = 0x00000010,
    V = 0x00000020,
    W = 0x00000040,
    Z = 0x00000080
  }
"@

# Define options for the @Copy statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum CopyOptions {
    None = 0x00000000,
    A = 0x00000001,
    B = 0x00000002,
    C = 0x00000004,
    D = 0x00000008,
    E = 0x00000010,
    F = 0x00000020,
    G = 0x00000040,
    H = 0x00000080,
    I = 0x00000100,
    L = 0x00000200,
    M = 0x00000400,
    N = 0x00000800,
    O = 0x00001000,
    P = 0x00002000,
    R = 0x00004000,
    S = 0x00008000,
    T = 0x00010000,
    U = 0x00020000,
    V = 0x00040000,
    W = 0x00080000,
    X = 0x00100000,
    Y = 0x00200000
  }
"@

# Define options for the @Data statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum DataOptions {
    None = 0x00000000,
    E = 0x00000001,
    G = 0x00000002,
    H = 0x00000004,
    I = 0x00000008,
    J = 0x00000010,
    K = 0x00000020,
    L = 0x00000040,
    P = 0x00000080,
    Q = 0x00000100,
    U = 0x00000200,
    V = 0x00000400,
    W = 0x00000800,
    X = 0x00001000
  }
"@

# Define options for the @Delete statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum DeleteOptions {
    None = 0x00000000,
    A = 0x00000001,
    C = 0x00000002,
    N = 0x00000004,
    O = 0x00000008,
    R = 0x00000010,
    S = 0x00000020,
    U = 0x00000040,
    V = 0x00000080,
    Y = 0x00000100
  }
"@

# Define options for the @Elt statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum EltOptions {
    None = 0x00000000,
    A = 0x00000001,
    D = 0x00000002,
    E = 0x00000004,
    G = 0x00000008,
    H = 0x00000010,
    I = 0x00000020,
    J = 0x00000040,
    K = 0x00000080,
    L = 0x00000100,
    O = 0x00000200,
    P = 0x00000400,
    Q = 0x00000800,
    R = 0x00001000,
    S = 0x00002000,
    U = 0x00004000,
    V = 0x00008000,
    W = 0x00010000,
    X = 0x00020000
  }
"@

# Define options for the @Free statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum FreeOptions {
    None = 0x00000000,
    A = 0x00000001,
    B = 0x00000002,
    D = 0x00000004,
    I = 0x00000008,
    R = 0x00000010,
    S = 0x00000020,
    X = 0x00000040
  }
"@

# Define options for the @Msg statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum MsgOptions {
    None = 0x00000000,
    C = 0x00000001,
    H = 0x00000002,
    I = 0x00000004,
    N = 0x00000008,
    S = 0x00000010,
    W = 0x00000020
  }
"@

# Define options for the @Prt statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum PrtOptions {
    None = 0x00000000,
    B = 0x00000001,
    D = 0x00000002,
    E = 0x00000004,
    F = 0x00000008,
    I = 0x00000010,
    L = 0x00000020,
    M = 0x00000040,
    N = 0x00000080,
    P = 0x00000100,
    T = 0x00000200,
    U = 0x00000400,
    V = 0x00000800,
    Y = 0x00001000,
    A = 0x00002000,
    O = 0x00004000,
    R = 0x00008000,
    S = 0x00010000
  }
"@

# Define options for the @Qual statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum QualOptions {
    None = 0x00000000,
    D = 0x00000001,
    R = 0x00000002
  }
"@

# Define options for the @Run statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum RunOptions {
    None = 0x00000000,
    B = 0x00000001,
    D = 0x00000002,
    N = 0x00000004,
    O = 0x00000008,
    P = 0x00000010,
    R = 0x00000020,
    S = 0x00000040,
    T = 0x00000080,
    W = 0x00000100,
    X = 0x00000200,
    Y = 0x00000400
  }
"@

# Define options for the @SetC statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SetCOptions {
    None = 0x00000000,
    A = 0x00000001,
    I = 0x00000002,
    N = 0x00000004,
    P = 0x00000008
  }
"@

# Define options for the @Sort statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SortOptions {
    None = 0x00000000,
    A = 0x00000001,
    C = 0x00000002,
    E = 0x00000004,
    I = 0x00000008,
    K = 0x00000010,
    L = 0x00000020,
    M = 0x00000040,
    O = 0x00000080,
    S = 0x00000100,
    T = 0x00000200,
    X = 0x00000400,
    Y = 0x00000800,
    Z = 0x00001000
  }
"@

# Define options for the @Ssg statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SsgOptions {
    None = 0x00000000,
    A = 0x00000001,
    B = 0x00000002,
    C = 0x00000004,
    D = 0x00000008,
    E = 0x00000010,
    F = 0x00000020,
    G = 0x00000040,
    H = 0x00000080,
    I = 0x00000100,
    J = 0x00000200,
    K = 0x00000400,
    L = 0x00000800,
    M = 0x00001000,
    N = 0x00002000,
    O = 0x00004000,
    P = 0x00008000,
    Q = 0x00010000,
    R = 0x00020000,
    S = 0x00040000,
    T = 0x00080000,
    U = 0x00100000,
    V = 0x00200000,
    W = 0x00400000,
    X = 0x00800000,
    Y = 0x01000000,
    Z = 0x02000000
  }
"@

# Define options for the @Start statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum StartOptions {
    None = 0x00000000,
    B = 0x00000001,
    N = 0x00000002,
    P = 0x00000004,
    R = 0x00000008,
    T = 0x00000010,
    U = 0x00000020,
    V = 0x00000040,
    W = 0x00000080,
    X = 0x00000100,
    Y = 0x00000200,
    Z = 0x00000400
  }
"@

# Define options for the @Sym statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SymOptions {
    None = 0x00000000,
    A = 0x00000001,
    D = 0x00000002,
    F = 0x00000004,
    J = 0x00000008,
    K = 0x00000010,
    L = 0x00000020,
    N = 0x00000040,
    U = 0x00000080
  }
"@

# Define options for the @Use statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum UseOptions {
    None = 0x00000000,
    I = 0x00000001
  }
"@

# Define options for the @Xqt statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum XqtOptions {
    None = 0x00000000,
    A = 0x00000001,
    B = 0x00000002,
    D = 0x00000004,
    G = 0x00000008,
    H = 0x00000010,
    N = 0x00000020,
    S = 0x00000040,
    W = 0x00000080,
    X = 0x00000100,
    Z = 0x00000200
  }
"@

# Define @SetC operation
Add-Type -TypeDefinition @"
  public enum Operation {
    None,
    AND,
    OR,
    XOR
  }
"@

# Define @Test test type
Add-Type -TypeDefinition @"
  public enum TestType {
    TE,
    TNE,
    TG,
    TLE,
    TEP,
    TOP
  }
"@

# Define @SetC, @Test portion of condition word
Add-Type -TypeDefinition @"
  public enum PortionOfConditionWord {
    W,
    H1,
    H2,
    T1,
    T2,
    T3,
    S1,
    S2,
    S3,
    S4,
    S5,
    S6
  }
"@

# Define options for the @SsgFileIdExtra statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SsgFileIdExtraOptions {
    None = 0x00000000,
    C = 0x00000001,
    D = 0x00000002,
    E = 0x00000004,
    M = 0x00000008,
    N = 0x00000010,
    V = 0x00000020
  }
"@

# Define options for the @SsgFileId statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SsgFileIdOptions {
    None = 0x00000000,
    A = 0x00000001,
    B = 0x00000002,
    C = 0x00000004,
    E = 0x00000008,
    I = 0x00000010,
    L = 0x00000020,
    N = 0x00000040,
    O = 0x00000080,
    R = 0x00000100,
    S = 0x00000200,
    P = 0x00000400,
    T = 0x00000800
  }
"@

# Define options for the @SsgMargin statement
Add-Type -TypeDefinition @"
  [System.Flags]
  public enum SsgMarginOptions {
    None = 0x00000000,
    P = 0x00000001,
    R = 0x00000002
  }
"@

