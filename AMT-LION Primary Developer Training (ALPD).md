
Table of contents


1	Introduction	16
1.1	AMT LION Primary Developer Training	16
1.2	Attendees	17
1.2.1	Audience	17
1.2.2	Prerequisites	17
1.2.3	Learning objectives	17
1.3	Daily Time Schedule	18
2	Creating a New Application	20
3	Creating the Graphical Interface (Forms)	23
3.1	Application Form Types	23
3.2	Creating a New Application Form	23
3.3	Application Form: Options	26
3.4	Application Form: Screen Layout	27
3.4.1	Personal options for Forms	28
3.4.2	Canvas properties	30
3.4.3	Adding Labels	31
3.4.4	Object Inspector	32
3.4.5	Changing Object Inspector Properties	33
3.4.6	Saving	36
3.4.7	Adding an Edit Box	37
3.4.8	Moving a Visual Object	38
3.4.9	Grouping Controls (the Group Box)	40
3.4.9.1	Group behavior settings	42
3.4.10	Adding multiple Visual Objects	43
3.4.11	Adding a Panel	44
3.4.12	Adding a Button Group	45
3.4.13	Adding a Radio Button Group	49
3.4.14	Adding a Checkbox	52
3.4.15	Adding an Image	53
3.4.16	Creating a Keyboard Shortcut for a Visual Object	55
3.4.17	Selection of multiple Visual Objects	57
3.4.18	Aligning Visual Objects	59
3.4.19	Show all Visual Objects (list)	61
3.4.20	Changing the tab order of Visual Objects	63
3.4.21	Screen Preview	66
3.5	Opening Existing Forms	67
3.6	Documentation	68
4	Writing Code within a Form	70
4.1	Implementation	70
4.1.1	Definitions	70
4.1.1.1	Variable Types	72
4.1.2	System defined variables	77
4.1.2.1	Resok	77
4.1.2.2	Error	78
4.1.2.3	Other system variables	78
4.1.3	Display Section and Process Section	79
4.1.3.1	Display Section	79
4.1.3.2	Process Section	79
4.1.3.3	Initialization of definition variables	79
4.1.4	Routines	80
4.1.4.1	Creating a Routine	80
4.1.4.2	Calling a Routine	82
4.1.4.3	Displaying a Routine	82
4.1.4.4	Routine Variables	83
4.1.4.5	Creating a Routine with the Code Wizard	84
4.2	Basic Syntax and Commands	86
4.2.1	Adding comments and commenting out code	86
4.2.2	Assigning values	87
4.2.2.1	Simple Assignment	87
4.2.2.2	Simple Addition Assignment	87
4.2.2.3	Simple Subtraction Assignment	87
4.2.2.4	Arithmetic Assignment	87
4.2.2.5	Concatenation assignment	88
4.2.2.6	Assigning values between different variable types	88
4.2.2.7	Assignment truncation	89
4.2.2.8	Assigning a quote mark	89
4.2.3	If … Endif condition	90
4.2.3.1	One line “If” command	91
4.2.4	Send Message	91
4.2.5	Send Message and Exit	92
4.2.6	Exit	92
4.2.7	Switching between forms (Gotoform)	93
4.2.8	Refresh	93
4.2.9	Case statements	94
4.2.10	Loop … Endloop	95
4.2.11	Break	96
4.3	Code editor	97
4.3.1	Code completion	97
4.3.1.1	Automatic code completion	97
4.3.1.2	Manual code completion	98
4.3.2	Validating and saving code	99
4.3.3	Code Templates	100
4.3.4	Editing in block mode	102
4.3.5	Aligning code	103
4.3.5.1	Code collapsing and expanding	104
4.3.6	Highlight coding	105
4.3.7	Bookmarks	106
4.3.7.1	Setting a Bookmark	107
4.3.7.2	Navigating to a Bookmark	109
4.3.7.3	Clearing a Bookmark	111
4.3.8	Multiple view	112
4.3.9	Screen layout and implementation in one view	113
4.3.10	Go to line number	113
4.3.11	Undo and Redo	114
4.3.12	Navigating forward / backward	114
4.3.13	Code colors	115
4.3.14	Find	116
4.3.14.1	Where updated	122
4.3.15	Find and Replace	123
4.3.16	Print object listing	124
4.3.17	Code personal options	126
4.3.17.1	Code options	126
5	Creating the Runtime of the Application	129
5.1	Setting the initial form in the Application’s Global Options	130
5.2	Generation sets	132
5.3	AMT Developer Studio Generator	134
5.3.1	Installing and starting the AMT LION Generator	135
5.3.2	Generating an Application	136
5.3.3	Selecting objects for generation	136
5.3.4	Tracing generation requests	137
5.3.5	Generator status	139
5.3.6	Generator status Log	140
5.3.7	Generate current object	141
5.3.8	Generating from the Repository view	143
5.3.9	Generating required objects	143
5.4	AMT LION Runtime Files	144
5.4.1	Forms	144
5.4.2	Reports	145
5.5	Database Reorganization	146
5.5.1	Reorganizing the database	146
6	AMT Runtime Environment	147
6.1	Configuration	147
6.1.1	First tier	148
6.1.2	Second Tier	148
6.1.3	Third Tier	148
6.2	Running the Application	149
6.3	Form Flow	150
6.3.1	Form life cycle	150
6.3.2	Form behavior	151
6.4	AMT Screens Runtime Options	152
7	Creating the Database Schema’s of the Application	156
7.1	Database Objects	156
7.1.1	Creating a new Table	157
7.1.2	AMT LION maintained fields	158
7.1.3	Defining fields in a table	159
7.1.4	Deleting fields from a Table	161
7.1.5	Bulk mode	161
7.1.6	Indexes	163
7.1.6.1	Creating an Index	163
7.1.6.2	Saving and using Tables and Indexes	166
7.2	Checking in Objects	167
8	Data Access in the Application	171
8.1	Table Query	171
8.1.1	Table query read	173
8.1.2	Specifying the index	174
8.1.3	Specifying the index keys	174
8.1.4	Retrieval method	176
8.1.5	Where clause	177
8.1.6	Locking records	178
8.1.7	Resultokto	179
8.1.8	Retainptr	179
8.2	Free Query	180
8.2.1	Specifying the database	180
8.2.2	Writing the query	181
8.2.3	Executing the free query statement	181
8.3	Cursor queries	182
8.3.1	Cursor query functions	183
8.3.1.1	Findfirst	183
8.3.1.2	Findnext	184
8.3.1.3	Findprior	184
8.3.1.4	Findlast	184
8.3.1.5	Findcurrent	185
8.3.1.6	Where	185
8.4	Referencing Records Retrieved from a Table/Cursor Query	186
8.4.1	Assigning values to table/cursor query fields.	186
8.4.2	Block assigning	187
8.4.3	Inserting a record	188
8.4.4	Updating a record	189
8.4.5	Deleting a record	190
8.5	Code Editor Advanced	191
8.5.1	The Code Wizard	191
8.5.1.2	Insert statement	192
8.5.1.3	Select statement	193
8.5.1.4	Update statement	196
8.5.1.5	Print layout items	198
8.5.1.6	File layout items	200
8.5.1.7	Auto completion	200
8.5.1.8	Popup menu help	201
8.6	Database Issues	202
8.6.1	Lock time out	202
8.6.2	Deadlock	202
9	Data Inquiry and Maintenance in the Runtime	204
9.1	RTQuery	204
9.1.1	Table inquiry	204
9.1.2	SQL queries	205
9.1.3	RTQuery command buttons	205
9.2	Query Considerations	208
10	AMT LION Debugger	210
10.1	Generating Debug Objects	210
10.2	Running the Debugger	211
10.3	Debug window	215
10.3.1	Step in	215
10.3.2	Step over	215
10.3.3	Continue/Halt	215
10.3.4	Skip	215
10.3.5	Step out	215
10.3.6	Show next statement	215
10.3.7	Halt	216
10.3.8	Abort	216
10.3.9	Breakpoints	216
10.3.10	Conditional breakpoint	217
10.3.11	Save settings	219
10.3.12	Load settings	219
10.4	Object Explorer	220
10.4.1	Synchronize objects	221
10.5	Debug information	222
10.5.1	Messages	222
10.5.2	Trace	222
10.5.3	Output	223
10.5.4	Call stack	223
10.5.5	Watches	224
10.5.5.1	Adding items to the watch window	224
10.5.5.2	Changing watch values	225
10.5.5.3	Remove watches	225
10.5.5.4	Expanding or collapsing groups	226
10.5.5.5	(De)select watches	226
10.5.6	Debugger logging	226
10.5.6.1	AMT LION Debugger Host	227
10.5.6.2	AMT LION Debugger	227
10.5.6.3	Bug reports	228
11	Forms Advanced Possibilities	230
11.1	Changing visual object properties at runtime	230
11.1.1	Caption	231
11.1.2	Enabled	231
11.1.3	Font properties	231
11.1.4	Helptext	232
11.1.5	Readonly	232
11.1.6	Setfocus	232
11.1.7	Visible	232
11.2	Insertable forms	233
11.2.1	Creating an insertable form	233
11.2.2	Using an insertable form	234
12	Advanced options and code	238
12.1	Global Options	238
12.1.1	Options	238
12.1.2	Database options	242
12.1.3	Dates	245
12.1.3.1	MaskDefinitions	247
12.1.4	Documentation	247
12.1.5	Languages	247
12.1.6	Checking in global options and generating	249
12.1.7	Global definitions	249
12.1.8	Colors	250
12.1.9	Constant	251
12.1.10	Redefines	251
12.1.11	Sessiondata	251
12.1.12	Variables	252
12.1.13	Adding a new block	253
12.1.13.1	Options	254
12.1.14	Global definitions	255
12.1.14.1	Documentation	255
12.1.14.2	Relations	255
12.1.15	Global query variables	256
12.2	Dictionary	257
12.2.1	Inserting a dictionary item	258
12.2.2	Using dictionary items	259
12.2.3	Global Dictionary list	260
12.3	Dates	261
12.3.1	Today	261
12.3.2	Definition type date	262
12.3.3	Dateresult	262
12.4	Advanced Code Commands	263
12.4.1	With … Endwith	263
12.4.2	Loop While	264
12.4.3	Loop For	264
12.4.3.1	Labels and Goto	265
12.4.4	Continue	265
12.4.5	In	266
12.4.6	All	266
12.4.7	Copy	266
12.4.8	Replace	267
12.4.9	Unstring	267
12.4.10	IndexOf	268
12.4.11	RightCopy	269
12.4.12	Inspect	270
12.4.13	Random	273
12.5	Repeating visual objects	274
13	Routines	277
13.1	Global Routines	277
13.1.1	Insertable global routine	277
13.1.2	Performed global routine	280
13.1.3	Global DLL routines	281
13.1.4	External DLLs	283
13.1.5	Includable global variables	285
13.1.6	Startup and Closedown	287
13.1.7	Routine parameter passing	287
13.1.7.1	Optional parameters	288
13.1.7.2	Result value	289
13.2	Relations	290
14	List box and combo box	292
14.1	Adding a listbox	292
14.2	Adding a combo box	294
14.3	Runtime list boxes and combo boxes	295
14.3.1	Fillbox	295
14.3.2	Attachtobox	297
15	Application management	300
15.1	Multiple generation sets	300
15.2	Logging on to another generation set	301
15.3	Revision control	303
15.4	Revision control view	304
15.4.1	Revision control function buttons	305
15.4.1.1	Get newest	305
15.4.1.2	Get all newest	306
15.4.1.3	Edit (Lock)	306
15.4.1.4	Check in	307
15.4.1.5	Unlock	307
15.4.1.6	Delete	308
15.4.1.7	Revision history	309
15.4.1.8	Assigning a label	311
15.4.1.9	Promote to revision	312
15.4.1.10	Grant lock	313
15.4.1.11	Branch code	313
15.5	Revision Control using the Repository View	314
15.6	Revision Control using the Generate Release View	315
15.7	Lock view	317
15.8	Code line revisions	318
15.9	Branching	320
15.9.1	Creating a branch	321
15.9.2	Merging	323
15.10	Folders	325
15.10.1	Create a folder	325
15.10.2	Create a shortcut into a folder	327
15.10.3	Deleting shortcuts and folders	328
15.10.4	Folder revision control	329
15.11	Labels in the Repository	330
15.11.1	Assigning a label	330
15.11.2	Label management	332
15.11.3	Move a label into another generation set	333
15.12	Log	334
16	Reports	336
16.1	Create a new application report	336
16.2	Options	337
16.2.1	Printing options	337
16.2.2	Database options	338
16.3	Print Outputs	339
16.3.1	Print output properties	340
16.4	Print Layouts	341
16.4.1	Print layout visual controls	342
16.5	Implementation and routines	342
16.6	Assigning values to print layout items	342
16.7	Report Specific Code Commands	343
16.7.1	Print	343
16.7.2	Header	344
16.7.3	Level break	345
16.7.4	Skip	346
16.7.5	Wait	346
16.7.6	Saverecoveryname	347
16.7.7	Commit	348
16.7.8	Abort	348
16.7.9	Start report	349
16.7.10	Input	350
16.8	Code Editor Report Advanced Function	351
16.8.1	Report personal options	351
17	Report Runtime	353
17.1	Report Flow	353
17.2	Running a report in the runtime environment	354
17.2.1	Start report tab sheet	354
17.2.2	Start report in the AMT Control Center	357
17.2.3	Running a report from a sleeping / ever running report	357
17.3	Report management	358
17.3.1	Managing completed reports	359
17.4	Debugging a report	361
18	Files and AMT LION Applications	364
18.1	File handling	364
18.1.1	Files Id’s	365
18.1.2	Files Layouts	367
18.1.3	Add fill/read file layout items	371
18.1.4	File indexes	373
18.1.5	Shared layouts	374
18.1.6	Code commands for file handling	375
18.1.6.1	Readfile	375
18.1.6.2	Writefile	376
18.1.6.3	Sort	376
18.1.6.4	Namefile	377
18.1.6.5	Removefile	377
18.1.7	File functions and properties	378
18.1.7.1	Create	378
18.1.7.2	Open	379
18.1.7.3	Read	379
18.1.7.4	Eof	379
18.1.7.5	Addrec	379
18.1.7.6	Updaterec	380
18.1.7.7	Append	380
18.1.7.8	Deleterec	380
18.1.7.9	Close	380
18.1.7.10	Copyfile	381
18.1.7.11	Deletefile	381
18.1.7.12	Exists	381
18.1.7.13	Createddate and createdtime	381
18.1.7.14	Currentrecno	381
18.1.7.15	Lock records / unlock records	382
18.1.8	Global file definitions	382
18.1.8.1	Creating a global file definition	382
18.1.8.2	Using a global file definition	384
19	Advanced Code Management	386
19.1	Templates in the AMT LION Developer	386
19.2	Exporting and importing	388
19.2.1	Exporting	388
19.2.2	Importing	392
20	Script Management	396
20.1	Setting Up Scripts	396
21	Appendix A: AMT Developer Studio Keyboard Shortcuts	402
22	Appendix A: AMT Debugger Keyboard Shortcuts	403
23	Information and feedback	404

Exercise 1: Create application	22
Exercise 2: Create forms	69
Exercise 3: Create forms code	128
Exercise 4: Make the application run	155
Exercise 5: Create tables, indexes and check-in code	170
Exercise 6: Create code for table queries	203
Exercise 7: Use RTQuery in AMT Screens	209
Exercise 8: Use LionDebugger	229
Exercise 9: Create Insertable Form.	237
Exercise 10: Create Form with repeatable options.	276
Exercise 11: Using routines.	291
Exercise 12: Use list and combo boxes.	298
Exercise 13: Become familiar with folders and revisions.	335
Exercise 14: Create report	352
Exercise 15: Run a report	363
Exercise 16: Use file functions in a report	385
Exercise 17: Create templates	387
Exercise 18: Export sources	395

# Introduction
## AMT LION Primary Developer Training
AMT LION is a powerful 4th generation programming language. Together with the intuitive AMT Developer Studio, development teams can build and maintain large business applications in a manageable and controllable way.
This training introduces the fundamentals of AMT LION development, with the aim being to learn how to build and maintain AMT LION application(s) in AMT Developer Studio.
During the training a complete operational application will be built from scratch including online forms, database and batch reports. During this training, it’s important to complete all exercises in sequence.

The main topics are
- 1.1 Create online application – Section 3 - 4
- 1.2 AMT runtime environment – Section 5 - 6
- 1.3 Database – Section 7 - 9
- 1.4 Debugging – Section 10
- 1.5 Advanced coding – Section 12 – 14
- 1.6 Version management – Section 15
- 1.7 Batch reports – Section 16 – 17
- 1.8 File handling – Section 18

This training course is 16 sessions and consists of:
- 1.9 Walk through of training manual
- 1.10 Demonstration by the trainer
- 1.11 18 Exercises for the trainees

The training can be completed with an optional certification. This certification is recognized within the AMT LION community and registered by Asysco. The certification consists of an exercise that needs to be completed in 2 sessions without the help of the instructor. This training manual and the online help can be used for information.

## Attendees
### Audience
This training is intended for:
- 2.1 AMT LION developers
### Prerequisites
Attendees should at least have a basic working knowledge of the following:
- 2.2 Understanding of the English language on at least B1 (Intermediate, IELTS level 4) level. The training material and lessons are in English.
- 2.3 An internet browser like Microsoft Internet Explorer
### 2.4 Microsoft Windows environment
#### 2.4.1 Using the File Explorer
#### 2.4.2 Start programs
#### 2.4.3 Using the Windows Command Prompt
- 2.5 Any other programming language. This can be legacy languages like COBOL and Linc or object-oriented languages like VB.net and C#
### 2.6 AMT trainings
#### 2.6.1 AMT General Introduction
#### 2.6.2 AMT Developer Studio User Interface
#### 2.6.3 AMT Control Center Operations
### Learning objectives
After completed this training, the attendees will understand
- 2.7 The structure of the AMT Developer Studio repository
- 2.8 The transaction flow of an AMT LION form
and be able to
- 2.9 Maintain an AMT LION application in AMT Developer Studio
- 2.10 Use the online help information.


## Daily Time Schedule

Day 1
Session 1: 	1: Introduction
2: Creating a New Application
Exercise 1: Create application
3: Creating the Graphical Interface (Forms)

Session 2: 	Exercise 2: Create forms
4: Writing Code within a Form

Session 3:	4: Writing Code within a Form (Continued)

Session 4:	5: Creating the Runtime of the Application
Exercise 4: Make the application run

Day 2
Session 1:	6: AMT Runtime Environment
7: Creating the Database Schema’s of the Application

Session 2: 	Exercise 5: Create tables, indexes and check-in code
8: Data Access in the Application

Session 3:	9: Data Inquiry and Maintenance in the Runtime
Exercise 7: Use RTQuery in AMT Screens

Session 4:	10: AMT LION Debugger


Day 3
Session 1:	11: Forms Advanced Possibilities
Exercise 9: Create Insertable Form.
Session 2:	12: Advanced options and code

Session 3:	13: Routines
Exercise 11: Using routines

Session 4:	14: List box and combo box
Exercise 12: Use list and combo boxes.
15:Application management
Exercise 13: Become familiar with folders and revisions.
Time to finish any unfinished exercises

Day 4
Session 1:	16: Reports
Exercise 14: Create report
Session 2:	17: Report Runtime
Exercise 15: Run a report
Session 3:	18: Files and AMT LION Applications
Exercise 16: Use file functions in a report
Session 4:	19: Advanced Code Management
Exercise 18: Export sources

Day 5
Session 1 & 2 : Certification
# Creating a New Application

When the AMT Developer Studio is started for the first time with an empty Repository database no applications are show in the main view as in Figure 2-1.


Figure 2-1: Empty repository


To insert a new application right-click on AMT Enterprise Repository and select Insert Object->Insert Application.


Figure 2-2: Add new application


A dialog box will appear asking for the name of the new application.
A name for the new application should be entered here. It’s best practice to use all CAPITALS for object names (including the application name) to avoid naming problems. Only characters A-Z, numbers 0-9 and the ‘_’ are accepted. References to these objects in code are translated to all uppercase anyway.
As this example application, created during this course, is about managing  customer data ‘CUSTOMER_MANAGEMENT’ is used as the name in Figure 2-3.


Figure 2-3: Add application dialog box

After clicking ‘Ok’ the application is added to the AMT Developer Studio.


Figure 2-4: New application created

Exercise 1: Create application

# Creating the Graphical Interface (Forms)
## Application Form Types
End-users communicate with the application and its database through Forms.

Four different types of Forms can be defined, (see Figure 3-1: Repository Forms):

- 4.1 Application Forms
- 4.2 Insertable Forms
- 4.3 Popup Forms
- 4.4 Template Forms

End-user applications use forms from the folders ‘Application Forms’ and ‘Popup Forms’.
The folders ‘Insertable Forms’, (see section 11.2), and ‘Template Forms’ (see section 19.1) are for development purposes.

## Creating a New Application Form
To create a new application form, in the repository view, expand the ‘Forms’ folder.  Right-click on the folder ‘Application Forms’, click ‘Insert Object’ and then click ‘Insert Form’.


Figure 3-1: Repository Forms



The ‘Insert Form’ dialog box is displayed.


Figure 3-2: Insert Form dialog box



Once all the details have been entered click the ‘OK’ button.  The Application Form window appears, (see Figure 3-3: Application Form Options), with the ‘Options’ panel showing initially.


The left-hand panel in an Application Form shows the sections available within the Form and the right-hand side presents the details for that section.
In this example, the values from the previous dialog box, name and description (see Figure 3-2: Insert Form dialog box), are filled in with the values ‘CUSTOMER’ and ‘Customer Management’.


Figure 3-3: Application Form Options


## Application Form: Options





## Application Form: Screen Layout

To open the screen layout of a form, click on ‘Screen Layout’ (left-hand side of window). This presents the screen layout view.


Figure 3-4:Form Canvas

The screen layout window consists of the visual controls tool bar (standard and advanced) at the top and the screen layout canvas underneath. The canvas shows visually displays any elements the designed form. In Figure 3-4 the canvas of the new form is empty.
The button with the arrow control , the first control of the standard visual controls toolbar tab, is by selected by default. This indicates that the mouse is activated as a pointing/selection device only. In this mode developers select visual controls that are already on the screen layout canvas.
A tooltip displaying the function of the various toolbar buttons can be displayed by running the mouse over each of them.

### Personal options for Forms

Pressing the function key ‘F10’ opens the dialog box for setting the AMT Developer Studio options, (see Figure 3-5). In the left-hand side of this options dialog box are two tab sheets ‘Personal’ and ‘Global’.
It’s best practice that Global options are only changed by an AMT Developer Studio Lead Developer or Administrator as any changes here affect all AMT Developer Studio developers.
Global options include default properties for layout items, code templates (see section 4.3.3 Code Templates), and a warning message setting.
Personal options allows an AMT Developer Studio developer to set options just for themselves. These are registered on the workstation of the developer, and do not interfere with other developers' settings.
Within Personal options, the second tab sheet is for ‘Forms’, (see Figure 3-5). These settings allow for changes when working with a Form’s ‘Screen Layout’ designer.



Figure 3-5: Form layout options



### Canvas properties
Using the Object Inspector, the properties of a form can be set.

Figure 3-6: Canvas properties


### Adding Labels

A ‘label’ is used to display a fixed piece of text, or to display text that is altered programmatically, and cannot be changed by the user.
To add a label on the screen layout canvas, click the label button , on the standard visual controls toolbar. The button displays as depressed. Now simply click on the canvas where the label is to be created.


Figure 3-9: Adding a label

A Labels is created on the canvas and automatically gets the name, ‘DISPLAY_0’.  Once the label is created, the arrow-button is then automatically returned to the status of depressed, instead of the label button.

### Object Inspector
As soon as a visual object is added or selected, the ‘Object Inspector’ dialog box appears for that visual object, (see Figure 3-10).
It’s possible to switch off, or on, the automatic appearance of the Object Inspector by right-clicking anywhere in the left column of the Object Inspector, and deselecting/selecting the option ‘Stay On Top’ from the popup. The ‘F11’ function key can also be used to open the Object Inspector.


Figure 3-10: Object Inspector

All the properties of a visual object are displayed and maintained by the Object Inspector. The list of properties varies by type of visual object selected. In Figure 3-10 a label object’s properties are displayed.

Navigation and selection of properties in the Object Inspector is not only possible by mouse clicking in the properties of the Object Inspector, but also by using the arrow-up and arrow-down keys. Using the arrow keys is also a quick way, to let AMT Developer Studio accept the input, instead of using the Enter key when clicking in the properties.

### Changing Object Inspector Properties

Name
When creating any visual object, it is good practice to rename it to a logical name for clarity.
To change the name of a visual object, click in the property ‘Name’ of the Object Inspector, change the name, and press Enter. In Figure 3-11 ‘DISPLAY_0’ has been changed to ‘Disp_Title’.


Figure 3-11: Change label name
Caption
To change a label to a fixed piece of text, within the Object Inspector click on the property ‘Caption’ and enter the required fixed text. The fixed text is then displayed on the screen.
In Figure 3-12, the label property ‘Caption’ has been changed to ‘Customer Details’.


Figure 3-12: Changing Caption

Font
Within the Object Inspector the font of a visual object can be customized. To do this, select a visual object, then in the Object Inspector, click the property ‘Font’. A browse button , appears next to the property.
Clicking on the browse button displays the dialog box for the font selection, (see Figure 3-13). The Font Chooser dialog box appears, and allows changes for default font, font style, and size of a visual object. Change the font by selecting the required ‘Font’, ‘Font style’ and ‘Size’ from the provided lists. The effects ‘Underline’ and ‘Strikethrough’ and ‘Color’ can also be changed if desired. There are 16 quick choices for ‘Color’ in the drop down, or the color selector button to the right of it allows for picking any color.

A sample of your chosen settings is displayed in the ‘Preview’ box.
Click the ‘OK’ button to accept the changes.


Figure 3-13: Change font


In Figure 3-14, the caption font of the label has been changed. This has been changed to a font of ‘Verdana’, a ‘Font style’ of ‘Bold’, ‘Size’ of ‘18’, and a ‘Color’ of ‘Blue’.

Figure 3-14: Label color and font changed

### Saving

As soon as changes have been made to an object, AMT Developer Studio will indicate unsaved changes to the Form by means of the two save buttons  on the main AMT Developer Studio tool bar, (see Figure 3-14).
The left-hand button is for saving the current changes in the active window only. So, this would save the changes made in the form screen layout only. It is also possible to use the shortcut keys ‘Ctrl-S’ to save the changes in the form screen layout only.
The save button on the right, is for saving all the changes that a developer has made to the entire Form. For example, a developer might make changes in the ‘Screen layout’ as well as in the ‘Options’. Clicking the right-hand button saves all of these modifications in one step. Also, using the key sequence ‘Alt-F’ and ‘A’, will save all the changes of the current Form.
Once saved, both these buttons are greyed out, to indicate there no unsaved changed, (see Figure 3-15).


Figure 3-15: Form saved
### Adding an Edit Box
To add an edit box on the screen layout canvas, click on the edit box button , on the Form’s standard visual controls toolbar, and click on the screen layout canvas where the edit-box is to be created.
An edit box is created in this position, and is automatically given the name, ‘EDIT_0’.
To change the length of a visual object, click in the property ‘Length’ in the Object Inspector and change the value and press Enter. The edit box automatically re-sizes to the new length.  This length property indicates the number of characters accepted and not the width of the control itself.



Figure 3-16: Add an edit box

In Figure 3-16, the length of the edit box is changed to 8, and the ‘Type’ changed to numeric.  The name ‘cust_no’ has been given to the edit box, which is then displayed in the edit box itself.


### Moving a Visual Object

Sometimes, as in Figure 3-17, when a control is added (e.g. ‘Customer Number’ label), or the caption changed, there can be a bit of overlapping between visual objects.


Figure 3-17: Visual object position

To move an object to a new position on the screen layout canvas, click on the visual object, keeping the mouse button clicked down, and drag the visual object to the new desired position.

Alternatively, a developer can change the position of a visual object, by modifying the ‘Top’ and ‘Left’ properties in the Object Inspector.
This places the visual object to an exact position, measured in pixels from the very top and left of the screen canvas. In Figure 3-18, the overlapping label is moved to a position that allows both objects to be viewed clearly.


Figure 3-18: Move visual object
### Grouping Controls (the Group Box)

A Group Box is a visual object that is used to group other visual objects. To add a group box to the screen layout canvas, click on the group box button , on the standard visual controls toolbar, and click on the screen layout canvas where the group box is desired, (see Figure 3-19).



Figure 3-19: Add a group box

To resize a selected Group Box in one direction, click and drag one of the sizing markers that surrounds the group box. To resize the Group Box horizontally and vertically, at the same time, click and drag a corner marker.
To change the title for a group box, click the ‘Caption’ property in the Object Inspector and enter the title accordingly.

In Figure 3-20, the title is changed to ‘Customer Details’, the Group Box is enlarged, and other labels and edit boxes have been added.


Figure 3-20: Group Box parent-child relation

The relationship between a group box, and the visual objects in it, is a ‘parent-child’ relationship. The Object Inspector property ‘Parent’ conveys this idea, (see Figure 3-20).  It’s not possible to simply drag an object in or out of a group box. Objects must be added into the box to become a ‘child’.  This can be done by creating new controls in the group box, or alternatively, objects can be cut and pasted into a group box.
The positions of visual objects in a group box are set relative to the group box, not the screen layout canvas.  Properties, such as ‘Top’ and ‘Left’, are now pixel positions relative to the group box, not the screen layout canvas.  Additionally, when a Group Box is moved onscreen, all visual objects belonging to a group box remain in their position within that group box.
Child objects inherit the font properties that are set for the group box.
Deleting a group box also deletes all visual objects that are placed in that group box.
This parent-child relationship also applies to other grouping controls, like the Panel or a Scroll Box.
#### Group behavior settings

Through the Object Inspector the ‘enabled’, ‘read-only’ and ‘visible’ property can be set.

Enabled

- 7.1 Default value: True
- 7.2 If a Panel or Group Box is disabled (Enabled: False) all the child controls are displayed as disabled, but the values of the child control’s Enabled property remain intact
- 7.3 When the Panel or Group Box is enabled, child controls are displayed according to their own Enabled property
ReadOnly

- 7.4 Default value: False
- 7.5 If a Panel or Group Box is ReadOnly (ReadOnly: True) all child controls are displayed as ReadOnly, but the values of the child control’s Readonly property remain intact
- 7.6 When the Panel or Group Box is set to ReadOnly = false, child controls are read only according to their own ReadOnly property

Visible

- 7.7 Default value: True
- 7.8 If a Panel or Group Box is not visible (Visible: False) all child controls are also not visible
- 7.9 This property can be used to show or hide conditional information


### Adding multiple Visual Objects

Often a developer needs to add more than one visual object, of the same type, to the screen layout. In Figure 3-20, multiple labels and edit boxes were placed in a vertical row within a Group Box.
This can be accomplished in one repeated action.  Hold down the SHIFT key, click on the Edit Box button (on the standard toolbar), this locks the Edit Box button and each click within the Group Box creates a new Edit Box. Multiples of the  control can be created as long as the Edit Box button remains selected.


Figure 3-21: Adding multiple visual objects

To stop adding visual objects of the same type, click on the arrow button , which returns the mouse to a pointing device only.

### Adding a Panel

A Panel, like a Group Box, is a visual object that is used to group other visual objects. A Panel can also be used to improve the appearance of the form by using the ‘Bevel’ property. A Panel, unlike a Group Box, does not have a caption, otherwise it operates in exactly the same way as a Group Box.
To add a Panel to the screen layout canvas, click on the panel button , on the standard visual controls toolbar, and click on the screen layout canvas where the panel is desired.



Figure 3-22: Adding a Panel

Set the Enabled or ReadOnly property (explained in section 3.4.9.1).
### Adding a Button Group

In AMT Developer Studio buttons can be created as a single button, or a group of buttons.
A button can be conceptualized as a two-layer structure, in front: is the visual control represented as a button and hidden behind is the value of the button. At runtime when the user clicks on the button, its value is sent to the code of the form. This will be seen further in the code commands section 4.2.9 Case statements.
To add a button, simply click the button group button , on the standard visual controls toolbar, and click on the screen layout canvas where the button/button group is required.
In Figure 3-23 a button group is created within the existing Panel control (created earlier and re-sized for appearance).



Figure 3-23: Button group added in panel
To add the items (aka a button’s caption) and the value for a button, within the Object Inspector click on the property ‘Items Values Images’. A browse button, , will appear, similar to the one seen earlier when changing the font. Clicking this button opens the following dialog box, (see Figure 3-24)



Figure 3-24: Button group dialog

As an example, a button group with five buttons, ‘Inq’, ‘Add’, ‘Chg’, ‘Del’ & ‘Menu’ can be created.
Each row in the table at the top of the dialog represents a button in the button group. First click on the row containing the default text ‘<Item>’ and ‘<Value>’.
These values are then displayed in the ‘Item’ and ‘Value’ edit boxes.  Change Item to ‘Inq’ and the Value to ‘I’, and then click on the button ‘New’.
This allows for the addition of the item/value of the second button, by entering in the ‘Item’ edit box ‘Add’ and in the ‘Value’ edit box ‘A’. The process can be repeated for the third button and so on, until all needed buttons in the group are defined.
To delete a button, click on the appropriate row, and click the ‘Delete’ button, the items and values of the button are then removed.
To change the button order, click on the appropriate row and click on either the ‘Up’ or ‘Down’ button, and the items and values move accordingly.
The ‘Default’ option allows for one of the buttons to be set as the default when first entering the runtime form.
It is also possible to assign images to a button, and to have a different image depending on the state of the button (i.e. Up, Disabled, Clicked or Over). The image location then allows for the alignment of the image on the button. For this training button images will not be added.
After adding all the items and values, the dialog box looks like Figure 3-25.


Figure 3-25: Buttons configured

By clicking the ‘Ok’ button the dialog box closes and the items and values are defined as the button group.

It is likely that the button group will need resizing, which is done by clicking and dragging one of the sizing markers, (see Figure 3-26)



Figure 3-26: Move and resize button group
### Adding a Radio Button Group

Radio buttons, much like buttons, are defined as a group.
To add a radio button group, simply click the radio button group button, on the standard visual controls toolbar, and click on the screen layout canvas where the radio button group is required.
In Figure 3-27 the radio button group has been created in the ‘Customer Type’ Group Box.


Figure 3-27: Adding a radio button


To add the items and values for the radio buttons, click on the property ‘ItemsAndValues’ in the Object Inspector. A browse button appears, similar to the one earlier for button groups, clicking this button also opens a familiar looking dialog box.


Figure 3-28: Radio button Items and Values

This dialog box, (see Figure 3-28), operates much like that of button groups, except for the provision of images, with each row in this dialog representing a radio button, (see section 3.4.12 ).

In the next example, (see Figure 3-29), radio buttons ‘Company’ and ‘Private’ are created. It is possible that the radio button will need resizing, as can be seen in the example.



Figure 3-29: Radio buttons created

For this training the layout of the radio buttons is also changed to Vertical. Clicking the property ‘Layout’ in the Object Inspector and selecting the appropriate layout from the drop down list, allows the layout to be changed (see Figure 3-30).



Figure 3-30: Layout radio buttons changed
### Adding a Checkbox

A checkbox in AMT LION is a visual control with only two possible visual states, ‘Checked’ and ‘Unchecked’.
To add a checkbox, click on the Checkbox button, on the standard visual controls toolbar, and click on the screen layout canvas, where the checkbox is to be created.
Two properties (‘Checked’ and ‘Unchecked’) exist within the Object Inspector to send a value to the underlying code in the form to indicate if the check box is checked or unchecked, and must be entered.
In Figure 3-31 below a checkbox has been added to indicate if the customer is to receive mailings, a ‘Y’ is provided for ‘Checked’, and an ‘N’ is provided to indicate ‘Unchecked’. ‘Add to Mail List?’ is added to the ‘Caption’ property and the ‘LabelPos’ is changed from ‘Right’ to ‘Left’



Figure 3-31: Checkbox added
### Adding an Image

The visual control ‘image’ is used to create images on forms. Allowed image types are: ‘BMP’, ‘GIF’, ‘JPG’ and ‘PNG’ files.
To add an image, click on the ‘Additional’ tab sheet above the visual controls toolbar. This displays a toolbar of additional visual controls. Now click on the Image button , and click on the screen layout canvas, where the image is to be created as displayed in Figure 3-32: Image added.



Figure 3-32: Image added

Images can either be stored within AMT LION using an ‘Imagelist’ and accessed  with the ‘ImageList’ and ‘ImageIndex’ properties (as seen in this example), or the image file can be saved to the ‘Bitmaps’ directory, within the ‘Clientgui’ directory of the application, (see section 5.4 AMT LION Runtime Files).
For the purposes of this training an Imagelist will not be used, so the image must be saved to the ‘Bitmaps’ directory.


Once the image is saved to the Bitmaps directory, the file name, and extension of the image needs to be entered in the property “Filename” of the Object Inspector, (see Figure 3-32). The runtime environment always looks for images in the ‘Bitmaps’ directory so only the file name and extension needs to be entered.
To show the image in the designer, the image must also be copied to the folder of LionDev.exe.
If a file name is provided and the image file is not in this directory, the image on the screen layout canvas will show the AMT LION logo at design time, (this is also always true for gif images), and at runtime the image on the form will remain empty with no error being sent.
If the property “Resize image” is set to false, the actual size of the image file will determine the size of the image at runtime. If this property is set to true, then the size of the image control that the developer creates on the screen layout canvas at design time is the size of the image at runtime (the image is scaled to fit the control’s size properties).




### Creating a Keyboard Shortcut for a Visual Object

Like other Windows applications, keyboard shortcuts can be created for visual objects. These allow users at runtime to use the visual objects by pressing the keys ‘ALT’ and the defined letter at the same time. Shortcuts can be created for most visual objects including button groups, checkboxes, and radio buttons.
Create a keyboard shortcut by placing an ampersand, ‘&’, in front of the character that should be entered in combination with the ‘ALT’ key. Ensure that the shortcut character is not already used as a shortcut. In Figure 3-33 the action button group keyboard shortcuts have been added.



Figure 3-33: Button group keyboard shortcuts


The keyboard shortcut is indicated on the visual object by underlining the shortcut key to be used with the ‘ALT’ key, as can be seen in the action button in Figure 3-34. So, for example the ‘Inq’ button can now be selected at runtime by pressing the keys ‘ALT’ and ‘I’ at the same time.



Figure 3-34: Keyboard shortcuts displayed
### Selection of multiple Visual Objects

The selection of multiple visual objects allows the values of some properties to be adjusted in the Object Inspector all at the same time.
There are two ways of selecting multiple visual objects from the screen layout canvas. The first is by holding down the ‘CTRL’ key and dragging a square with the mouse around the required visual objects (keep the mouse click button depressed while dragging with the mouse, see Figure 3-35).



Figure 3-35: Selecting multiple objects
Upon releasing the mouse button, all the visual objects within the square are selected.


Figure 3-36: Multiple objects selected

The second way to select multiple objects is by clicking the visual objects one after the other while holding down the ‘CTRL’ key.
It is also possible to select all the visual objects on a screen layout canvas. Either by the standard Windows keyboard shortcut (‘CTRL’ + ‘A’), or by clicking the speed button ‘Select All’ , on the main AMT Developer Studio toolbar, (see Figure 3-36). This button can also be used in the ‘Implementation’ section for selecting all the code.
Only objects on the same level can be selected at the same time (i.e. objects having the same ‘parent’).
Once selected any adjustments in the Object Inspector will be applied to all selected visual objects.
It is also possible to copy and paste all the selected objects from one form’s layout to another.

### Aligning Visual Objects
Pressing the ‘F4’ key opens the ‘Align’ dialog box which contains speed buttons to align multiple visual objects, (see Figure 3-37).
The alignment is based on the first object selected when using the ‘CTRL’ key pressed down. If multiple selections are made by dragging a square around the objects, or using select all, (described in the previous section), then objects are aligned based on the selected object that is nearest the top left corner.
To align visual objects first select the objects to be aligned. In Figure 3-37 the ‘Telephone Number’ label is selected first, then the remaining ‘Customers Details’ labels.


Figure 3-37: Multiple objects selected for alignment


Clicking the speed button “Align right edges”,  on the “Align” dialog box, right aligns the visual objects to that first selected object (i.e. the ‘Telephone Number’ label).



Figure 3-38: Objects right-aligned
### Show all Visual Objects (list)

To get a full list of all the visual objects on a form, right-click somewhere on the screen layout canvas and choose from the popup menu the option ‘Show Items’, (see Figure 3-39).


Figure 3-39: Show Items

The view of the Screen Layout changes to show all of the visual objects, and their attributes. From this view, items can be selected which recalls the Object Inspector where only the name property can be changed, (see Figure 3-40).


Figure 3-40: Items list

To return to the screen layout canvas, right-click somewhere in the right side of the window and now select ‘Show Paint’ from the popup menu, (see Figure 3-41).


Figure 3-41: Return to form’s screen canvas




### Changing the tab order of Visual Objects

In the runtime application, the end user can navigate between visual objects using the ‘tab’ key. Changing the tab order of visual objects is done by right-clicking in the Screen Layout canvas, and choosing ‘Taborder’ from the popup menu, (see Figure 3-42).


Figure 3-42: Change tab order
This opens a dialog box containing all visual objects that can obtain focus at runtime, (see Figure 3-43).
The tab order of the visual objects within a group box or a panel are defined within the group itself. The method of doing this is described later in this section.


Figure 3-43: Tab order dialog box
The listed tab order is changed by clicking the up button , or down button , as required.
In Figure 3-43 the ‘PANEL_0’, needs to be the last item listed. To change this, select the control by clicking it, then click the down button, moving the control down the list (continue this until it is the last item in the list then click the ‘OK’ button).
Alternatively, the above could also have been achieved by clicking the button ‘Auto Tab’. This automatically changes the tab order of the visual objects so they are listed from the top left through to the bottom right of a form screen layout.
To change the tab order within a panel, or group box, right-click within the panel or group box on the screen layout canvas and again select “Taborder” from the popup menu.
This time the dialog box only contains the visual objects that can have focus within that panel or group box, (see Figure 3-44). The order can be changed in exactly the same way as described above.


Figure 3-44: Tab order of Group Box

It is also possible to change the tab order within the Object Inspector with the ‘Tabnumber’ and ‘Tabstop’ properties, (see Figure 3-45)


Figure 3-45: Tab order in Object Inspector

The ‘Tabnumber’ property in the Object Inspector allows for the changing of the numeric tab number value that is used to determine the tabbing order of visual objects.
It is also possible to completely switch off tabbing into an object by setting the ‘Tabstop' to False.

### Screen Preview
On the main AMT Developer Studio tool bar there is a speed button “Preview”, , (see Figure 3-45).
Pressing this button opens a dialog box that gives a preview of what the form will look like at runtime, (see Figure 3-46).



Figure 3-46: Screen preview
## Opening Existing Forms
An existing form can be opened in one of two ways. The first is by double-clicking on the form object in the repository view. The second is by entering the form name in the ‘Open’ command box, (see Figure 3-47).



Figure 3-47: Opening existing form in repository

As with creating a form, when a form is opened, it first displays the ‘Options’ section, (see Figure 3-3).


## Documentation

Users of AMT Developer Studio can add information within the ‘Documentation’ section of an object. To add Documentation, select the ‘Documentation’ section from the navigation tree, then the option ‘Add new documentation section’. This presents a dialog box seen in Figure 3-48 for specifying the documentation folder name.

Figure 3-48: Add new Documentation section

Once the name is entered click the “OK” button. The documentation section is added to the navigation tree, and text can be added in the window on the right.

Figure 3-49: Documentation section
It’s also possible to add a URL by typing ‘http://’, or just ‘//’, immediately followed by a URL address, (see Figure 3-49). Links to files can also be added in documentation by typing ‘file:\\’, or ‘\\’, immediately followed by the path to the file.
Only one URL address or link can be added per line of documentation. The link can be followed by simply clicking on it.
Exercise 2: Create forms

# Writing Code within a Form
## Implementation

The code lines and declarations of a form are placed in the ‘Implementation’ section. The Implementation of a form consists of four subsections, (see Figure 4-1),

- 10.1 Definitions
- 10.2 Display section
- 10.3 Process section
- 10.4 Routines

Together these sections define all of the business rules of a form to be executed at runtime.
All the code lines of the ‘Implementation’ are displayed consecutively in the right-hand section of the window, known as the code editor.
### Definitions

Selecting ‘Definitions’ in the left-hand navigation tree displays the code on the right from line 1 where the definitions start. In Figure 4-1, no code has yet been added. The AMT LION section headers of the code are presented only.


Figure 4-1: Default code structure

Within the Definitions section of the code (i.e. between the ‘begin_definitions’ and ‘end_definitions’), are four subsection headers, ‘const’, ‘var’, ‘retained_var’ and ‘booleans’, (see Figure 4-1). This is where variables that are local to a form are declared. No actual code commands are included in the Definitions section.
const
In the subsection ‘const’ (Constant), read only variables with a fixed value are defined. In this subsection the constant item must be specified with the keyword ‘value’, and the actual fixed value (values that never change are good candidates for constants).

var
The subsection ‘var’ (Variables), is where variable items are declared. These may be declared with an initial value, but this is not required, as the values of these variables are normally set, or changed, within the code of the form.
retained_var
The subsection ‘retained_var’ (Retained Variables) contains the variable items where the values are retained throughout the user’s session and are not initialized at the start of a transaction in a form, as with all other definitions, (see section 4.1.2 System defined variables). The maximum available space for storing retained variable values for each separate transaction is limited to 8000 bytes.
booleans
In the subsection ‘booleans’ are defined read only boolean items. There are only two predefined possible values ‘true’ or ‘false’. This is explained further in the next section  under the subsection Booleans.

shared_layouts
A fifth subsection ‘shared_layouts’ can be manually added to the definitions. In this subsection file layouts are specified that together use the same piece of memory. A change of the value in one of these file layouts reflects also in the layouts that are defined as shared. This is described in further detail in section 18.1.5 Shared layouts.

Any of the above subsections can be removed from the definitions if they are not used and are empty.
#### Variable Types

Definitions have many types. The most commonly used are explained here.
Regarding variable names, they may be any mix of alphanumeric characters (with at least 1 alphabetic character required). Prefixes such as ‘vc’ or ‘vn’ are not required, but are used here to provide clarity.  The special characters ‘_’ and ‘-‘ are allowed in names, but spaces and other special characters are not.




Figure 4-2: Example definitions

The example syntax in Figure 4-2 is explained in detail in the forthcoming sections.
alpha
An alpha item has a fixed length that may contain all ASCII characters.
Example syntax:
vc-not-known  : alpha 9  value 'Not Known'
va-street     : alpha 20

string
A string may contain all ASCII characters, but has no predefined length. The maximum length of a string is theoretically unlimited, and is limited only by physical disk space. In practice, it is safest to assume a maximum length of 2 Gigabytes for strings.
Example syntax:
vst-text : string

numeric
A numeric item has a fixed length that contains positive numbers only. A Numeric type may also have decimal values.
Example syntax:
vn-custno     : numeric 8
vn-countdown  : numeric 3 value 100
vn-amount     : numeric 6.2

signed
A signed item has a fixed length that contains positive or negative numbers. A Signed type may also contain decimal values.
Example syntax:
vn-signed-amt : signed 6.2
vn-signed-num : signed 8

integer
An Integer contains numeric signed values only. Integers cannot contain decimal values. An integer has no predefined length. The length is up to a maximum of 18 numeric digits.
Example syntax:
vi-total : integer

structure
Variables can be grouped in the definition section into so called structures.
If a value in the program code is assigned to a structure, it will change not only the structure value, but also all the associated sub variables of the structure. The same applies the other way around, where a value is assigned to a sub variable, which is part of a structure. This will also change the value of the structure variable.

Example syntax:
vs-customer : structure
va-first-name : alpha 20
va-last-name  : alpha 20
end_structure

If a customer name of ‘Andrew              Smith’ is assigned to the structure vs-customer (defined above) va-first-name contains the value ‘Andrew’, and va-last-name contains the value ‘Smith’.
If ‘Brian’ is then assigned to the variable va-first-name the structure
vs-customer then contains the value ‘Brian               Smith’.
Since a structure is a variable itself, its name within the object (form, report, etc.) must be unique.
Variables that are declared within structures however may have the same name as ones that occur in other structures.
It is also possible to nest structures within each other as can be seen in the example syntax below.
Example syntax:
vs-screen-data : structure
vn-cust-no  : numeric 8
filler      : alpha 1 value ','
vs-customer1 : structure
va-firstname : alpha 20
va-lastname  : alpha 20
end_structure
filler      : alpha 1 value ','
vs-custname2 : structure
va-firstname : alpha 20
va-lastname  : alpha 20
end_structure
end_structure

So, in the above example, when referring to va-firstname or va-lastname, it must be qualified with the structure name. The variable (as referred to in the code) becomes:
vs-customer1.va-firstname

Filler
As can be seen in Figure 4-2, and the Example syntax: ‘filler’ is a reserved name for definitions and unlike other variables can be declared multiple times with this name. This is also true when declaring file layouts, (see section 18.1.2 .

array
All variable types can be declared as an array. In the definition, the maximum number of occurrences must be entered within square brackets. This then allows for a series of variables, which can be referenced in the code with the index number within square brackets. Multi-dimensional arrays are allowed for up to a maximum number of six dimensions.
Example syntax:
va-country      : alpha 20 [100]
vn-num-2d-array : numeric 8 [10,10]

Like all variables, an array variable is initialized at program start-up and memory is reserved for this variable. Creating an array with too many elements will use up memory that’s not required for the application to operate efficiently.

boolean
A boolean has only two predefined possible values, ‘true’ or ‘false’.
If a boolean is set up in the ‘var’ section, it is defined as a variable, which the developer uses to store a boolean value.
Example syntax
var
vb-isOK : boolean

If defined in the ‘booleans’ subsection it is an implicit boolean and must have a corresponding expression defined, which can also be multiple expressions. The value of an implicit boolean at runtime will automatically be changing with the value of the variables used in its expression.
In the first example below, at runtime if vn-countdown contains a value of 0, then vb-end-countdown is equal to true otherwise the value will be false.
Example syntax:
booleans
vb-end-countdown : (vn-countdown = 0)
vb-amount        : (vn-amount > 10 and vn-amount < 10000)



Format Option for Variables.
The ‘format’ option is allowed for numeric variables as well as for alphas. It is very useful to define the formatting of numeric data for instances where the item is assigned to a string, or is part of a structure. For alphanumeric variables, the character ‘B’, to indicate a space insert, can also prove useful.

Example syntax:
vn-amt-4-2 : signed 6.2 format '-ZZ99.99'

If ‘1.23-‘ is assigned to the above variable, it will be automatically formatted to
‘-01.23’.


redefines
Using the ‘redefine’ option, two or more variables can use the same piece of memory. An update in one of these variables also automatically updates the value in the other variable(s).
The ‘redefine’ option is available not only to a local variable, but also to a file item, or even a report layout item. All fields must have a fixed size, so a string or an integer is not a valid type.
Example syntax:
var
vc-months : alpha 36 Value 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'
vs-month  : structure redefines vc-months
va-month : Alpha 3 [12]
end_structure


Multiple variable definition
It is possible to define multiple variables of the same type and length in one definition line by separating each variable with a comma. Please consider code maintenance and readability if using this concept.
Example syntax:
Var
vs-string1, vs-string2, vs-string3 : string
va-var1a, va-var2a, va-var3a       : alpha 1


### System defined variables
When creating a new application within AMT Developer Studio a series of system definitions are automatically defined. These system variables are available for developers to use while building program code. Some of these variables are read only, but others are free to use and update.
The most important, and most often used, system variables are ‘resok’ and ‘error’

#### Resok
The system variable ‘resok’ is a boolean variable. Its name is an abbreviation of ‘result ok’.
During runtime, this variable is automatically set to true or false at various times. The following are a few examples of when the value of ‘resok’ will change.
In the following circumstances ‘resok’ is set to true:
- 10.5 After successful ‘insert’ of a record into the database
- 10.6 After a ‘loop endloop’ table query if at least one record is retrieved
- 10.7 After the ‘getfirst’ table query if a record is retrieved

In the following circumstances ‘resok’ is set to false:
- 10.8 After failing to ‘insert’ a record into the database
- 10.9 After no record at all has been retrieved with a ‘loop endloop’ table query.
- 10.10 After no record has been retrieved with a ‘getfirst’ table query


#### Error
The system maintained variable ‘error’ is also a boolean variable type. This system variable can also be assigned a value in the program code.
There are three commands that implicitly set ‘error’ to true. These are ‘Refresh’, ‘Gotoform’ and ‘Smex’.
The value of this variable controls the action to be performed at the end of a screen transaction when the last line of the program code has been executed. If ‘error’ is false then the system enters the ‘display_main’ routine, and if the value is true the system returns to the start of the ‘process_main’ routine and leave all screen contents intact (this can be seen in the screen flow diagrams in section 6.3 Form Flow).
Also, when ‘error’ is true no inserts/updates into the database are performed.

#### Other system variables

The following tables contains examples of other useful system variables:

Table 4-1: System variables

### Display Section and Process Section
The concept of a ‘display section’ and a ‘process section’ in AMT LION directly relate to two routines ‘display_main’ and ‘process_main’, respectively (these are reserved names within AMT LION and other routines cannot go by these names). These routines often contain all code commands that define the business rules of a form.
#### Display Section
The display section routine, ‘display_main’, must be present in each and every form.
The program code of this routine is automatically executed just before the screen is presented to the end user, and is normally used to fill the controls on a form with data.
#### Process Section
Like the display section, the process section routine ‘process_main’ must be present in each and every form.
The program code of this routine is automatically executed the moment an end user transmits (presses enter), clicks a push button on the screen, or double-clicks on a visual object that executes the process main (e.g. a list box or combo box).
#### Initialization of definition variables
At the start of the routines ‘display_main’ and ‘process_main’, the variable values that are not defined in the ‘retained_var’ subsection of the definitions, are automatically initialized.
The AMT runtime environment does this implicitly, so no additional coding is needed.
Variables that are declared with an initial value are restored to that initial value. If no initial value is specified for a variable then it is initialized in the following manner:
- 10.11 Numerics are set to zeros
- 10.12 Integers are set to zeros
- 10.13 Alphas are set to spaces
- 10.14 Strings are set to spaces
- 10.15 Booleans are set to false

### Routines
Routines are the building blocks of the business logic. Apart from the two AMT LION routines ‘display_main’ and ‘process_main’ contained within forms, developers can freely create and name their own routines (excluding any reserved words). There are no limits to the number of routines that a program object may contain.  Best practice is to give routines clear names that indicate what they are meant to accomplish.
Routines may be placed in any sequence within the code editor, as long as they are not inside another routine.
Each form can have one finalize routine. This routine will always be executed at the end of the transaction. This is always at the end of display_main and at the end of process_main. The routine may not return a result and always has to contain one parameter of type String.


Figure 4-3
#### Creating a Routine
To create a routine, click on the ‘Implementation’ sub item ‘Routines’, then in the right side of the window click on the option ‘Add new routine’. A dialog box will appear to specify the routine name, (see Figure 4-4).


Figure 4-4: Create routine
Enter the routine name and click the ‘OK’ button.
In the Figure 4-5 the routine named ‘menu_button’, from the previous dialog box, is added to the form. When creating a new routine, a new item under ‘Routines’ on the navigation tree appears with the routine name, and the routine template is added to the code editor.



Figure 4-5:’menu_button’ routine added

A routine can also be added by typing directly in the code editor, ‘routine <name of routine>’, ‘begin_routine’ and ‘end_routine’ and either saving or validating the object.


#### Calling a Routine
To execute a routine, it must be called from within another routine. This may even be from the AMT LION included routines ‘display_main’, or ‘process_main’.
A call to the routine is followed by parentheses. In Figure 4-6, the routine called ‘menu_button’ is called from within the ‘process_main’ routine.



Figure 4-6: Call a routine

#### Displaying a Routine
There are two methods to easily display the code of a routine. One is to select the routine listed in the ‘Routines’ section of the navigation tree. The other is to double click in the code editor on the code line where the routine is called. Both of these methods take the code editor immediately to the start of the routine.
This is probably not so apparent in Figure 4-6 where there is only one routine, but in large programs with many routines this quickly becomes a helpful navigation tool.
To help show exactly where the cursor is positioned in the code editor, the relevant section is highlighted in the left-hand navigation tree, (see Figure 4-6).
#### Routine Variables
All routines in a form can access and use the variables and constants that are declared in the ‘Definitions’ section of that form.
Variables defined in the ‘Definitions’ section, (except those in the ‘retained_var’ subsection), are as advised earlier, only initialized at the start of the routines ‘display_main’ and ‘process_main’.
Constants and variables, (but not booleans, redefinitions, or retained variables), can be defined that are local to the routine. These variables and constants are initialized each time a routine is executed.
To enter constants and variables for a routine, first enter the headers ‘const’ and ‘var’, between the routine name and the ‘begin_routine’ header, (see Figure 4-7).



Figure 4-7
The constants and variables declare locally are accessible to this routine only, and are not available by routines.
The names of these constants and variables must be unique to the program code and not be found in the ‘Definitions’ section. Apart from that, variables and constants that are declared with the routine are unique to that routine, so this then allows for variables to be defined with the same name within other different routines.

#### Creating a Routine with the Code Wizard

The code wizard within AMT LION helps the developer add standard code layouts. The code wizard is explained in more detail in section 8.5.1 .
To start the code wizard, click in the code editor where the code is to be inserted, then either right mouse click and select ‘Code Wizard’ from the popup menu, (see Figure 4-8), or use the shortcut keys ‘CTRL’ and ‘W’.



Figure 4-8: Using ‘Code Wizard’


After this the Code Wizard menu appears. Select the third option “Routine”, (see Figure 4-9).



Figure 4-9: Code Wizard dialog

Then enter the name of the new routine, (see Figure 4-10), and click the ‘Finish’ button.



Figure 4-10: Code Wizard Routine name

The new routine is then added to the code editor at the position specified, in the same way as seen previously in Figure 4-5.
## Basic Syntax and Commands
There are a multitude of commands available in AMT LION. The following are commands that are commonly used and may be useful in completing this training’s exercises.
### Adding comments and commenting out code
Comments can be added in any area of the code editor, including ‘Definitions’. By default, comments are colored green.
To add a whole line of comment, begin the line with two forward-slashes. Anything added after these two forward slashes will be a comment, (see Figure 4-11, code line 20).
Comments can also be added at the end of a code line by entering two slashes after the line of code. Again, anything added after the two forward-slashes is a comment, (see Figure 4-11, code line 23).


Figure 4-11: Comments in code
Blocks of comments can be added within curly brackets, ‘{’ and ‘}’. The symbol ‘{’ starts the comment, and the symbol ‘}’ ends the comment block, (see Figure 4-11, code lines 33-34).
The double slashes and curly brackets can also be used to comment out lines or blocks of code, so that they are not executed.
### Assigning values
Values can be assigned in many ways to various items (e.g. variables, screen objects, report layout items, etc).
#### Simple Assignment
A value is simply assigned to an item by using the simple assign command, which is a colon with an equals sign (e.g. ‘:=’).
Example syntax:
vn-count      := 3
va-firstname  := 'Andrew'

#### Simple Addition Assignment
The Addition assign command is a plus sign in front of an equals sign (e.g. ‘+=’).
Example syntax:
vn-count += 1
vn-total += vn-amount

In this example, vn-count is increased by 1, and vn-amount is added to the variable vn-total.
#### Simple Subtraction Assignment
The subtraction assignment works similarly to the addition assignment, except that a subtract sign is used instead of a plus sign (e.g. ‘-=’).
Example syntax:
vn-count   -= 1
vn-balance -= vn-amount

#### Arithmetic Assignment
As well as simple addition and subtraction assignments seen in the previous two sections, any valid arithmetic expression can be used to assign a value into a numeric item.
Example syntax:
vn-count := vn-lastcount + 1
vn-perc  := vn-dec-amt * 100
vn-avge  := (vn-yeartot / vn-mths) + (vn-lstyeartot / 12)


#### Concatenation assignment
A concatenation assignment is the linking of items into one item. This is done with an ampersand (e.g. ‘&’).  If a numeric, signed, or integer is used then the item will be automatically converted before execution as follows:
- 11.1 Numeric to alpha (decimal characters used in decimal values are omitted)
- 11.2 Integer to string
- 11.3 Boolean to alpha

Examples syntax:
va-fullname := va-firstname & ' ' & va-lastname

The concatenation assignment appends items to the previous item, and by default, any trailing spaces in the previous item are lost. In order to keep any trailing spaces in the previous item the ‘notrunc’ command should be added to the assignment statement.
Example syntax
va-fullname := va-firstname & ' ' & notrunc(va-lastname)

The ampersand can also be used within the assignment statement itself (e.g. ‘&=’), but be aware that this always append to the existing value.
Example syntax:
va-fullname := va-firstname
va-fullname &= ' ' & va-lastname

#### Assigning values between different variable types
It is possible, with some limitations, to assign values between different assigned types. The types used in the assignment command will determine the alignment of the assignment.
The table below shows the assignments between different types that are recognized by AMT Developer Studio, and how the alignment is handled. Other assignments are not supported and will produce unpredictable results in the AMT runtime environment.

Table 4-2: Variable type alignment
#### Assignment truncation
Where assignment occurs between items of different lengths, truncation can occur from the right, or the left. The alignment diagram in the previous section shows where the truncation occurs.
Example syntax :
vn-len5 := 12345
vn-len4 := vn-len5

In the above example vn-len5 is defined as a numeric, length 5, and vn-len4 as a numeric, length 4. This results in vn-len4 having a value of ‘2345’, therefore truncation has occurred on the left side, as alignment is to the right.
In the example below va-len5 is now defined as an alpha, length 5, and va-len4 as an alpha, length 4.
Example syntax:
va-len5 := 'abcde'
va-len4 := va-len5

The result of the above is that va-len4 has a value of ‘abcd’. Therefore, truncation has occurred on the right side, as alignment is to the left.
#### Assigning a quote mark

To assign a quote mark, it must be prefixed with a further quote mark.
Example syntax:
va-text := 'The first name is ''' & va-firstname & '''.'

va-text := 'The first name is ''Andrew''.'

Assuming that the item va-firstname contains a value of ‘Andrew’, then both the above statements will assign the value, ‘The first name is 'Andrew'.’ to va-text.


### If … Endif condition

There are two ways to use the ‘if … endif’ command. It can be written as a block of program code, or as one line of code.
When defined as a block of program code, the ‘if’ statement must eventually be linked with an ‘endif’. The ‘else’ and ‘elseif’ branches, seen in Figure 4-12, are optional.

Figure 4-12: If..EndIf

Example syntax:
if vn-countdown = 0
vn-countdown := 100
else
vn-countdown -= 1
endif


An ‘elseif’ can be repeatedly used to avoid writing a lot of ‘if … endif’ commands in a row.
Example syntax:
if vn-phase = 0
vn-phase :=1
elseif vn-phase = 1
vn-phase := 2
else
vn-phase := 3
endif

#### One line “If” command
The one line ‘if’ command construct is seen in Figure 4-13. Used this way the line of code does not need an ‘endif’ command. The ‘else’ parameter, seen in Figure 4-13, is optional. This example performs the same function as the first example in the block construct. It is a matter of opinion as to which is more readable.

Figure 4-13: Inline If statement
Example syntax:
if vn-countdown = 0 then vn-countdown := 100 else vn-countdown -= 1

### Send Message
The ‘sendmessage’ command,  abbreviated as ‘sme’, sends a message to the form. This does not set the ‘error’ system item (explained further in section 0).

Figure 4-14: SendMessage
The ‘expression’ and ‘2nd expression’, are the values to be used in the first and second parts of the message respectively.  These can be literals or items. At least one expression must be specified.
The destination defines where the message needs to be sent. This is an optional item, but if specified, it can only be one of three values, which must be between quote marks.
- 11.4 ‘ALL’	- Sends the message to all users of the application
- 11.5 ‘ODT’	- Sends a message to the AMT Control Center (the message can be viewed in Alerts > Messages)
- 11.6 ‘<station name> - Sends a message to a specified station

When not specified, the message is displayed on the screen to the user.

Example syntax:
if vn-count > 0
sme (vn-count, 'Count has been exceeded’)
endif

if va-logoff = 'Y'
sme ('Request:', 'Please logoff immediately', 'all')
endif
### Send Message and Exit
The command ‘smex’ is similar to the sendmessage command in that it sends a message to the form, however unlike the sendmessage command, it also automatically sets the system item ‘error’ to true, and ends the execution of the current routine, (see section 0).


Figure 4-15: SMEX
As well as setting the expressions, like the ‘sendmessage’ described in the previous section, it is also possible to optionally specify the visual object where the cursor will be positioned after the execution of this command, (this is the ‘Focus field’ in Figure 4-15).
Example syntax:
if custno = 0
smex ('Request', 'Enter Customer number’, custno)
endif

### Exit
The ‘exit’ command will end the current routine immediately. If the current routine is ‘display_main’ or ‘process_main’ the entire screen transaction is aborted.
If the current routine is nested within another routine, then the program execution returns to the ‘calling’ routine.
Example syntax:
routine countdown
begin_routine
if vn-countdown = 0
exit
else
vn-countdown -= 1
endif
end_routine


### Switching between forms (Gotoform)
The command ‘gotoform' is used to send the end user to another form after the transaction of the current form is completed.


Figure 4-16: GotoForm

If extra help screens are defined for this form, one of these can be displayed with the use of the optional second parameter, (see Figure 4-16). This will then show the help screen on an extra tab sheet.
The additional optional parameter ‘NEW’ allows for opening the form as a new tab sheet. This opens a new sub session within AMT, which must be defined in the options of the application.
If more than one “gotoform” is encountered in a form transaction, only the last will be executed.
Example syntax:
if button_menu = 1
gotoform ('customer')
endif

Using gotoform(BYE) closes the entire application whenever and wherever it is called.

### Refresh
This command ‘refreshes’ or repaints the current form using the current screen values. Section 6.3 explains the process in more detail.


Figure 4-17: Refresh

If, for this form, extra help screens are defined, one of these can be displayed with the use of the optional parameter, (see Figure 4-17). It will then show the help screen on an extra tab sheet.
Example syntax:
refresh ()
refresh ('error_help')
### Case statements
The ‘startcase … endcase’ statement, which can be abbreviated as ‘sc …ec’.  This command is used to test multiple values in one pass. Execution of the code lines are dependent on the value of the specified ‘item’ in the ‘startcase’ statement matching the specified ‘value list’ in the ‘case’ statement, (see Figure 4-18).
The construct of a ‘startcase … endcase’ statement can be seen in Figure 4-18.


Figure 4-18: StartCase

The else command, (see Figure 4-18), is optional.
The value list can have multiple possible values and it is also possible to define a range in the value list by using two dots. Examples of both these can be found in the syntax below, which deals with the testing of button values.
Example syntax:
sc button_menu
cs 1
gotoform ('customer')

cs 2 3 4			//Multiple Values
gotoform ('reports')

cs 5..8			//Range of Values, i.e. 5, 6, 7, 8
sme ('These forms are currently under construction')
ec


### Loop … Endloop
To create an unconditional loop in program code, use the ‘loop … endloop’. An unconditional loop is infinite, so it becomes the responsibility of the developer at design time to build in a break, (see next section), somewhere in the loop.
The construct of a ‘loop … endloop’ statement is shown in Figure 4-19.



Figure 4-19: Loop

Example Syntax:

vn-count := 0
loop
vn-count += 1
get-text-line ()
if vn-count > 100 then break
endloop


### Break
The statement ‘break’ as seen in the previous section is used to immediately end a loop. The additional operand ‘outmost’ ends all nested loops in one action.



Figure 4-20: Break

Example Syntax:
vn-count := 0
loop
vn-count += 1
get-text-line ()
loop
get-parameters ()
if va-no-parameters = ‘Y’
break outmost
else
if va-no-parameters = ‘N’
break
endif
endif
endloop
if vn-count > 100 then break
endloop
## Code editor

AMT Developer Studio’s code editor contains numerous features to make working with it easy.
### Code completion
Like other modern code editors, AMT Developer Studio includes code completion.
There are two ways to access this:
- 12.1 Automatic, after typing a dot “.”,
- 12.2 Manual after pressing ‘CTRL’ + ‘Space’

#### Automatic code completion

Figure 4-21: Automatic code completion

Properties of screen and report objects can be set in the code. After typing the name of the object and a dot, these properties are shown in a list box as shown in above example. The desired property can be selected by double clicking it with the mouse or selecting it with the cursor keys and pressing ‘Enter’.


#### Manual code completion
Manual code completion can be used on any variable. To enable this, the key combination ‘CTRL’ + ‘Space’ needs to be pressed.


Figure 4-22: Manual code completion

After typing the first letters, press ‘CTRL’ + ‘Space’ and all variables and routines containing these letters will be shown in the list box as shown in the above example.
The correct variable can be selected by selecting it with the mouse (double-click), or selecting it with the cursor keys and pressing ‘Enter’ or by continuing to type which narrows the possible items listed.


Figure 4-23: Auto completion


### Validating and saving code

It is both important, and required, before generating in AMT Developer Studio that the developer validates the current object which checks the syntax. This can be done by clicking the ‘Syntax Check’ speed button , or by pressing function key ‘F8’. When the object’s changes are simply validated, and not saved, all changes can still be undone using the Windows shortcut keys ‘CTRL’ and ‘Z’.


Figure 4-24: Validate code

After validating, a dialog box appears to advise of the result of the validation. Any errors and warnings are listed in the bottom of the window, (see Figure 4-24).
After clicking the button “OK” to close the dialog box, error(s) can be clicked on to immediately show the line in the code editor with the error. The line can then be corrected and revalidated to ensure clean generation.
Warnings should not cause a generation to fail, however, they should still be looked at as they may cause problems in the runtime environment or future releases.

Before the object can be generated the program code must be saved. This is done exactly the same way as with the screen layout by using the save button(s)  on the main AMT Developer Studio tool bar, or the shortcut keys ‘CTRL’ + ‘S’ to save only the code, or ‘ALT’, ‘F’ and ‘A’ to save all changes in the object.
The function key ‘F7’ performs the combined action of saving all the changes and validating the object.
### Code Templates
In the code editor, templates can be used to make writing code faster and easier.
Templates can be created and maintained in the Global Options section by an AMT Developer Studio Administrator. Default templates are provided in AMT Developer Studio for the ‘if’ and ‘for’ commands, (see Figure 4-25). Templates stored in the Global Options are available to all developers.



Figure 4-25: Code template



To use a template, type the name of the template on the line where the code template should be added. In Figure 4-26 the template ‘rou’ is entered on a new line.


Figure 4-26: Code template auto completion


Press ‘CTRL’ + ‘Enter’, the template code is inserted, (see Figure 4-27).



Figure 4-27: Code inserted from template
### Editing in block mode

To select a block, press the ‘ALT’ key and hold it down. Then place the cursor at the starting point of the selection with the mouse and click the left button on the mouse and also keep it held down. Drag the cursor to the end of the block that needs selecting. Finally release the ‘ALT’ Key and the mouse button, a block of code is now selected as shown in the example below. This enables the developer to cut, copy and paste in columns instead of complete text lines, (see Figure 4-28).



Figure 4-28: Block mode editing



### Aligning code

As well as the ‘Indent’ speed button , and ‘Unindent’ speed button , a further speed button ‘Align Code’ , exists on the code editor tool bar to automatically indent the program code and make it more readable. In Figure 4-29 code lines 28 to 32 require indenting.


Figure 4-29: Aligning code

Clicking the ‘Align Code’ speed button or pressing the function key ‘F4’ indents all nested blocks by 4 character positions, (see Figure 4-30)


Figure 4-30: Auto indenting

Even though previous changes may not have been saved, once the code has been aligned by either clicking the speed button or pressing ‘F4’, these changes can no longer be undone using the shortcut keys ‘CTRL’ and ‘Z’.
#### Code collapsing and expanding
As may have already become apparent the code editor has a number of  buttons next to the code line numbers, (see Figure 4-30). These buttons allow for collapsing sections of code.
For example, clicking the  button on line 24 of Figure 4-31 collapses the code of the ‘if’ statement. The code is shown as collapsed by the button changing to a plus sign. The code line ends with ‘…’ to indicate that the code is collapsed (see Figure 4-31).



Figure 4-31: Collapse code

To expand the code back into view, click the plus button on line 71.

When the mouse pointer is moved over the [-] indicator, the start and end of the code structure is indicated bold. See Figure 4-31 the code structure that starts with ‘if CUST_NO >’

### Highlight coding
It is possible to highlight a complete piece of coding like if ... end-if or start case ... endcase by double clicking on the statement.
This is also applicable for structure ... end structure.


Figure 4-32: Code Highlighting

The highlighted code can be “commented” and “uncommente” by using the buttons  on the toolbar of the logic edit window. This function will only work when the object is locked (in edit-mode).
### Bookmarks
Bookmarks mark a line in the program code that allows for easy return. To create a bookmark, use the shortcut keys ‘CTRL’, ‘SHIFT’ and a numeric key, or right-click on the line where the bookmark is required and from the popup menu select ‘Toggle Bookmarks’ and select the ‘Toggle’ required, (see Figure 4-33). The ten numeric keys allow for up to ten different bookmarks being created in one object.


Figure 4-33: Bookmarks


#### Setting a Bookmark
In Figure 4-34 ‘Toggle 0’ has been selected, to create bookmark ‘0’ on line 18.


Figure 4-34: Bookmark indicator

Immediately to the right of the line number appears a  icon indicates a bookmark, (see Figure 434).
On the code editor toolbar there is a “Used bookmarks” drop-down list box.


Figure 4-35: Bookmark drop-down list

The bookmark drop-down list contains the object where a bookmark is created and on which line of code, (See Figure 4-35).
These bookmarks are remembered while navigating throughout the AMT Developer Studio, as long as the window with the bookmark is not closed. It is also possible to define bookmarks across applications.


#### Navigating to a Bookmark
To return to a bookmark either select the bookmark from the drop-down list, or if it is a bookmark within the current object or a uniquely numbered bookmark, use the shortcut ‘CTRL’ and the numeric key entered previously. It is also possible to right-click and from the context menu select ‘Goto Bookmarks’ and then select the bookmark required, (see Figure 4-36).


Figure 4-36: Goto bookmark


This then returns the cursor to the line of code remembered by the bookmark, (see Figure 4-37).



Figure 4-37: Returned to bookmarked line


#### Clearing a Bookmark
To clear a bookmark either go to the line with the bookmark and use the shortcut keys ‘CTRL’, ‘SHIFT’ and the numeric key of the bookmark, or right-click in the code editor and from the context menu select ‘Toggle Bookmarks’ and deselect the ‘Toggle’ bookmark.
It is also possible to clear multiple bookmarks by right-clicking in the bookmark drop down list and selecting from the context menu ‘Clear Bookmarks’ and then selecting ‘This Object’, ‘This Application’ or ‘All’, (see Figure 4-38).



Figure 4-38: Clear bookmark
### Multiple view

The Windows Presentation Foundation (WPF) functionality (explained in the AMT Developer Studio User Interface training), enables the developer to have multiple views of the same code. This can ease the maintenance of the code. It’s not necessary to jump from one place to another. One window is open in ‘edit’ mode, and all others are clones and read-only. This is indicated in the heading as shown in Figure 4-39: Multiple views.


Figure 4-39: Multiple views

Clones can be closed by the close button at the right-hand top corner.


### Screen layout and implementation in one view
The same concept explained in the previous section can be used to view the screen layout and the code. By resizing the windows, it’s possible to get all information on one screen as shown in Figure 4-40.


Figure 4-40: View on layout and code

### Go to line number

A speed button exists in the code editor to go to a specified line number, .
Clicking this button, or when the cursor is in the code editor pressing the keyboard shortcut ‘ALT’ + ‘G’ presents a dialog box to enter the line number of the code to go to, (see Figure 4-41). Once the line number is entered, and the ‘OK’ button clicked, the cursor jumps to the indicated line of code.


Figure 4-41: Go to line number dialog

### Undo and Redo
Two speed buttons exist in the code editor to ‘undo’ changes to an object,, or ‘redo’ changes, .
The usual Windows keyboard shortcut of ‘CTRL’ and ‘Z’ is also available for the undo function.
The undo and redo are only available for changes that are not yet saved, or aligned.

### Navigating forward / backward

Figure 4-42: Navigate buttons

In the code, double-clicking on a routine’s name navigates to the code of the routine. To jump back to the line where the routine was called, the ‘Navigate backward (‘CTRL’ + ‘-’)’ key  can be used. To jump forward again, the ‘Navigate forward (‘CTRL’ + ’SHIFT’ +’-’)’ key  can be used. This function works inside an object like a form, but also works with calls to routines outside the object (e.g. Global Routines).
### Code colors
The code editor of the AMT Developer Studio is dynamically context-sensitive. This means that while typing code in the editor the colors of the code automatically adjust depending on the context of the code that is typed. This indicates AMT LION syntax structure.
For example, when typing the command ‘gotoform’, as soon as the ‘m’ is typed AMT Developer Studio recognizes the word ‘gotoform’ as a command / keyword and changes the color to blue.
Different colors are given depending on the context of the code. The default colors of AMT Developer Studio are:
- 12.3 Red for strings or numbers
- 12.4 Blue for commands
- 12.5 Teal (medium blue-green) for labels
- 12.6 Green for comments
- 12.7 Black for identifiers

These colors can be adjusted to personal preference by selecting the menu item ‘Edit’ + ‘Options’ from the AMT Developer Studio menu, and choosing the ‘Lion Code colors’ tab.  This may assist developers with color sensitivities, where two colors may appear the same.

### Find
In the code editor the standard windows shortcut ‘CTRL’ + ‘F’ presents the ‘Find’ dialog box, (see Figure 4-43). This allows searching for specific text within the source code.


Figure 4-43: Find dialog
Search text is entered in the search combo box, and the ‘Find button is clicked.
The ‘Where’ section, (see Figure 4-43), allows a search to be performed in the ‘Current frame/element’, ‘Current object’, ‘Whole application’, or ‘All applications’.
The ‘Directions’ section specifies which direction the search is conducted.
The search can be further refined, by checking any of the following five ‘Options’, (see Figure 4-43): ‘Save search options’, ‘Match Case’, ‘Complete word’, ‘One Result/object’ or ‘Regular Expression’.


- 12.8 Complete Word - Only find values where the whole word matches
- 12.9 One Result/object - returns only one item found per object when searching within the ‘Where’ options ‘Current object’, ‘Whole application’, or ‘All applications’.

- 12.10 Regular Expression - allows for wildcard searches, or the matching of the start or end of the line:

^  - A circumflex at the start of a string matches the start of a line
$  - A dollar sign at the end of an expression matches the end of a line
*  - An asterisk after a string matches that string followed by any wildcard characters. For example, bo* matches ‘bot’, ‘bo’ and ‘boo’ but not ‘b’
\  - A backslash before a wildcard character ensures that the next character in the search string is treated literally, and not as a wildcard. For example, \^ matches ^ and does not look for the start of a line


If searching within the ‘Current frame/element’, after starting the find the cursor jumps to the first line on which the entered string is found and highlights this item. In Figure 4-44 a find was performed for the word ‘menu’.


Figure 4-44: Search result

Pressing the function key ‘F3’ then performs a ‘find next’, for the next occurrence of ‘menu’.


When using the ‘Where’ option ‘Current Object’, the Find dialog box changes, (see Figure 4-45).


Figure 4-45: Find dialog extended

Two new search options are provided ‘Search scope’ and ‘Look in’, (see Figure 4-45).
The radio buttons of ‘Search scope’, can be selected to limit the search within the ‘Current object’ and only display the ‘Result at the bottom’ of the code editor, or ‘Result in a new window’.
The ‘Search scope’ also allows for searching in objects called by this object, by selecting the ‘Including children’ option, or searching within objects calling this object with the ‘Including parents’ option. It is also possible to search objects that exist in another application and are called by this object by selecting, ‘Including children (remote)’. Results from these searches are displayed in a new window.
The ‘Look in’ choices a developer can select/deselect the areas of the object in which to search. Clicking the ‘[A]’ button selects all areas, and ‘[N]’ deselects all.
With the ‘Where’ options ‘Current object’, ‘Whole application’, and ‘All applications’ it is possible to search for a second word with the drop down list options of ‘AND’ or ‘OR’, or to remove a word from a search with the option ‘AND NOT’.
When the results are displayed in a new window, they are displayed as appears in Figure 4-46.



Figure 4-46: Search result list

The search criteria is outlined at the top of the window, and the results in the main section of the window, giving the object name, type and description, and the element of the object it is found in, including any line numbers, (see Figure 4-46).
It’s possible to search within these search results, by entering a search value in the ‘Search inside result’ box and clicking the ‘Search button, (see Figure 4-46). The ‘Append’ option allows for the search results to be appended to the current results window. If appended, then the append column will be incremented by 1 for the new results.
Double clicking on one of the results opens the object at the point where it’s found. If this is in the code editor, then the specific line of code is highlighted.
It is also possible by right-clicking in the results window to bring up a popup, (see Figure 4-46), the appearing context menu allows for selecting all results, copying the selected results (e.g. to other applications, Notepad, Excel, etc), or printing the selected results.
When using the ‘Where’ option ‘Whole application’, the ‘Find’ dialog box again changes, (see Figure 4-47).


Figure 4-47: Find dialog ‘Whole application’


The object types to be searched can be limited by selecting the object type(s) to be searched. When the ‘[…]’ button is clicked, a dialog similar to a repository view pops up. Individual objects can be selected by ticking their related box.

Figure 4-48: Selecting objects for find

Once the objects are selected, clicking the ‘Ok’ button returns the ‘Find’ dialog box with the object group now ‘Selected’, (see Figure 4-49). Now when the find is performed, only the objects selected will be searched in.



Figure 4-49: Finalize find instruction


What can also be seen from Figure 4-49 is that if a find has already been performed, then the option to append new finds to the results window is also possible here.
The final ‘Where’ option ‘All applications’ looks similar to the dialog box in Figure 4-49, except that the option to select objects or object groups in the ‘Entire Application’ section is no longer available.

#### Where updated
Clicking the tab sheet ‘Where Updated’ at the top of the Find dialog box presents two new fields ‘Table’ and ‘Field’, (see Figure 4-50). The remaining options available are the same as the Find options described in the previous section.


Figure 4-50: Find ‘Where updated’

Entering the table and field name and clicking the ‘Find’ button, returns where the field specified is updated.


### Find and Replace

The shortcut key ‘CTRL’ + ‘H’ opens the ‘Replace’ dialog box, (see Figure 4-51).



Figure 4-51: Replace dialog

This allows for the entry of a value to find and a value with which it is replaced.
The buttons allow for the following:
- 12.11 Finding the next occurrence
- 12.12 Replacing the next occurrence
- 12.13 Replacing all from the cursor position down
- 12.14 Replacing all within the current object

An option exists to also match the find text on case and whole word.
### Print object listing

With an object open, if the ‘Print’ speed button , on the main AMT Developer Studio toolbar, is clicked the ‘Print’ dialog box appears, (see Figure 4-52).



Figure 4-52: Print dialog

This dialog box is used to produce a listing of the source of the object. The check boxes in the top left section default to the area of the object that was open when the button was clicked, optionally other areas of the object can be selected for printing.
The ‘Code printing’ section allows for printing line numbers. Also, rather than printing the whole object, the option ‘Selected block’ can print only a selected area is printed. In addition, insertable items (reports only) can be printed. If enabled, all inserted objects that are called in the report will be appended to the print. When ‘Print index’ is checked, an index of the routines is included at the end of the listing.

The ‘General Options’ section allows the selection of ‘Header/Page numbers’ for printing and for the print lines to wrap.
The ‘Font ’button allows the font to be changed from the default.
‘Margins’ allows the print margins to be changed.
Clicking the ‘Ok’ button produces a source listing similar to what appears in Figure 4-53 when printed.


Figure 4-53: Print example
### Code personal options
In addition to the settings explained in the AMT Developer Studio User Interface training, a few settings can be configured to help create consistent and well-structured code.
#### Code options

Clicking the tab sheet ‘Code Options’ within ‘Personal Options’ (F10) allows the setting of personal options for the code editor, (see Figure 4-54)


Figure 4-54: Code options

Case
The ‘Case Option’ only applies to code wizards and code completion, (see section 8.5.1 ), and only specifies the case of the code when it is created from a wizard or through auto completion. The developer can still manually enter code in either uppercase or lowercase, irrespective of the setting here.


Alignment
‘Alignment’ options are only executed when the save and validate function key ‘F7’ is pressed. They are not executed with the Save or Validate speed buttons.
‘Remove empty lines except the last’ removes any additional blank lines, (i.e. when more than one blank line exists between code lines, additional blank lines are removed) so that only one blank line remains.
The option ‘Align Assignments under each other’ when set, will align blocks of assignment commands on the assignment character.
The option ‘Align Comment’ when set, aligns blocks of comment code.
If the option ‘Auto align code when F7 is pressed’ is checked, then whenever a developer presses ‘F7’ to validate and save the object, the code is automatically aligned.

Warnings
The choices within the ‘Warnings’ section allow the developer to filter warning messages they receive in the code editor when validating the object.

Use smart tabs
‘Use Smart Tabs’ makes the tab key in the code editor jump more efficiently to a new column instead of always indenting with a fixed number of positions.

Sort routine treeview
When this option is unchecked, the routines created in objects, are shown in the left-hand navigation tree, in the order in which they appear in the code editor. When this option is checked, they appear in alphabetical order.

Display line after column
When checked an additional vertical line will be displayed in the editor behind the column number entered.

Exercise 3: Create forms code

# Creating the Runtime of the Application
Creating a runtime of the application is performed by taking the following steps:

- 12.15 Set an initial form in the Application’s Global Options
- 12.16 Configure a valid generation set
- 12.17 Install and start the AMT LION Generator (service)
- 12.18 Generate the runtime of the application
- 12.19 Reorganize the runtime database
- 12.20 Configure the app.ini



Figure 5-1: Creating runtime environment flow

In the simplified figure above, the AMT processes and modules required for the online runtime environment are shown. A text in an arrow indicates a related setting (i.e. LionDev needs the ‘Lion.ini’ file to communicate with the AMT Developer Studio repository).


## Setting the initial form in the Application’s Global Options

When an application is created, a set of global options for the application are also created, these options are valid throughout the entire application. Each application in a repository has its own unique set of application options.
The global options are also kept as an object of the application. To access the global options right-click on the application folder, and from the context menu select ‘Options’, (see Figure 5-2).



Figure 5-2: Open application options

This opens the options window for the selected application.

In the Global Options window, the main options of the application are maintained, (see Figure 5-3).


Figure 5-3: Application options

The field ‘Initial Form’ specifies the form that is presented to the user when the runtime application is first opened. Typically, this is a logon form, or a menu.
To change the ‘Initial Form’ the global options object needs to be ‘locked’. To lock the global options object, click the ‘Edit Object’ button , from the main developer toolbar, (see Figure 5-3). Locking objects is looked at in more detail in section 15.3 Revision control.
Once the Global Options are locked by the developer, the ‘Initial Form’ can be entered or changed. After making changes, the Global Options must be saved by clicking the save speed button, or the pressing ‘F7’ key.
Other Global Options are explained in more detail in section 12.1 Global Options.
## Generation sets

A generation set can be regarded as a version of your developed application, which includes all related objects and code; it is possible to define multiple generation sets. For example, there might be a 'Development' set, a 'Functional Test' set, ‘Production’ and so forth.
As development progresses, and code is proven, object revisions are generally promoted from one generation set to another. Objects are edited and generated in each generation set independently of other generation sets.
A generation set defines a few properties including the physical location for the set of the generated runtime application. Therefore at least one generation set must be defined to generate the application.


In a generation set, in the Parameters field, a number of switches can be set that will influence the way the generator generates the application. For more information on these parameters, visit the online help manual.

To enter the Generation Set view of the AMT Developer Studio, enter ‘GENSET’ or ‘GS’ in the ‘Open’ command box.


Figure 5-4: Generation Set

The minimum requirement for a valid generation set is a name for the generation set is a name in the ‘Name’ field and a folder in the ‘Local Source folder’ field. The runtime of the application is generated into this source folder.
In a development environment, the option ‘Generate objects in edit’ should be checked.  This enables the generation of objects that are locked and contain changes that are not yet been checked into the repository.




## AMT Developer Studio Generator
Before the application can be generated the AMT Developer Studio Generator (Windows) service must be installed and started. This can be controlled in the ‘Supervisor’ tab of the Generator view of the AMT Developer Studio. To enter the ‘Generator’ view enter ‘GEN’ in the ‘Open’ command box (or by pressing the ‘F6’ function key).


Figure 5-5: Generate window

### Installing and starting the AMT LION Generator
Click the ‘Supervisor’ tab. The generator can be installed as a Windows service by clicking the ‘Change/Install’ button. The Binary file ‘LionDevGennet.exe’ is located in the same installation directory of the AMT Developer Studio.


Figure 5-6
Once installed it can be started by clicking the ‘Start’ button and stopped with the ‘Stop’ button. While active the ‘Service status’ shows ‘Running’ in green.


Figure 5-7



### Generating an Application
The first generation of an application must always be a ‘Whole System’ generate. For this purpose, the button ‘Whole System’ is provided, (see Figure 5-5).
Once the full application is generated once, all following generation processes can be partial generations, unless the system options change in which case a whole system generation is recommended.

### Selecting objects for generation
The tab sheets ‘Forms’, ‘Popup Forms’, ‘Reports’, ‘Performable global routines’, ‘Global routine dlls’, ‘Consumable Webservices’ and ‘Providing Webservices’ list all objects in the application. This list can be filtered with the ‘Display <> generated’ checkbox, which when checked, only displays objects requiring generation.
The tab sheet ‘System’ contains three groups of objects, ‘Database’, ‘Global Definitions’ and ‘Application’. Since the content of these groups are generated as one object, it’s not possible to check a member of these groups.
Each object has a checkbox, which when selected marks the object for generation. As shown in Figure 5-5, the AMT Developer Studio automatically recognizes which objects are newly created, or changed, and sets this checkbox accordingly.
A developer can choose to generate additional objects, by checking the object’s checkboxes. Two further buttons ‘Select All’ and ‘Select None’ are also provided to aid selection, (see Figure 5-5).
When the checkbox ‘Private debug’ is checked a debug version of the object(s) are generated. This is covered in more detail in section 10.1 Generating Debug Objects (until that part of the training, leave this unchecked).
By selecting from the ‘Priority’ list box the generation priority can be changed. The default value is ‘Normal’, (see Figure 5-5).
To start the generation of only selected objects, click the ‘Generate’ button.

### Tracing generation requests
The tab sheet ‘Requests’ shows all queued generation requests that are made by developers, (see Figure 5-8).



Figure 5-8: Generation requests


The tab sheet ‘Generation status’ displays all current and completed generation processes, (see Figure 5-9). This tab also shows the Generation Set that the object(s) are generated against. Generation Sets are covered in more detail in section 15.1 Multiple generation sets. There is also a message indicating whether a reorganization of the database is required following the generate (see section 5.5 Database ).


Figure 5-9: Generation progress

### Generator status
The tab sheet ‘Supervisor’, (see Figure 5-10) is only accessible to developers with Administrator rights. From this tab sheet the current status of the AMT Generator Service can be examined. This tab sheet also provides controls so that the AMT Generator Service can be stopped, started, controlled, or amended. These are AMT Developer Studio Administrator functions.


Figure 5-10: Generation Supervisor

All of this information is stored in the Source Repository database (see the REVGENSTATUS table).

### Generator status Log
The information about the generation process is also stored in a logfile on disk per application. In the folder ‘<GenSetFolder>\Development\Log’ will be a subfolder for the specific day, here you will find a file called ‘_Generate ccyymmdd.Log’ (where ccyymmdd is the specific day).

Figure 5-11: Generation log example


### Generate current object
It is also possible to generate an object, from within the object itself.  To do this, either press the keys ‘SHIFT’ and ‘F6’, or click the ‘Generate this object(s)’ speed button, , on the main developer toolbar.
This opens the ‘Objects To Generate’ dialog box, (see Figure 5-12).


Figure 5-12: Generate single object

When the dialog box is first opened, it shows the current number of queued generate requests. In a multiuser development environment, there may be many simultaneous generate requests being made. This then helps the developers to understand if there is a queue for generation resources.
The generate priority can be selected from the ‘Priority’ list box, which defaults to a priority of ‘Normal’.
The ‘Private debug’ checkbox generates the object in debug mode. This is looked at in more detail in section 10.1 Generating Debug Objects, at this time, leave it unchecked.
When the option ‘Generate all children….’ is checked, related objects are also generated.
Click the button ‘Generate’ or press the ‘enter’ key, to start the generation of the listed object(s).

Once the generation is requested the status line changes to show the current progress, (see Figure 5-13).



Figure 5-13: Object generating
It is possible to close the generate dialog box by clicking the button ‘Close’, (see Figure 5-13). This does not interrupt the objects being generated, and allows the developer to continue working whilst the generation is running. The developer can check the generation status of their objects in the generate window’s tab sheets ‘Requests’ and ‘Generation Status’, (see section 5.3.4 ).
If the generate dialog box is left open, and the generation is completed successfully, the dialog box automatically closes. If there are errors in the generation process the dialog box remains open and displays the error(s), (see Figure 5-14).


Figure 5-14: Generation error(s)

### Generating from the Repository view
It is also possible to generate an object, or multiple objects, from the repository view. Select an object to be generated by clicking on it, or multiple objects by the standard Windows method of using the ‘SHIFT’ or ‘CTRL’ keys and clicking the objects, (see Figure 5-15)


Figure 5-15: Generate from repository view
Once the required objects are selected, click the ‘Generate this object(s)’ speed button , on the main developer toolbar. The dialog box seen in Figure 5-12 opens, listing the object(s) to be generated. The same process can then be followed as described in section 5.3.7.

### Generating required objects
If an object is changed that is called by, or used in, another object, then when generating this object, AMT Developer Studio automatically recognizes which objects need generation and lists these in the ‘Objects to Generate’ dialog box, (see Figure 5-12). For example, if a table or an index is changed, then generating the table/index causes all of the objects that use this table or index to be generated too.
## AMT LION Runtime Files
The AMT Developer Studio Generator creates an application directory, (see Figure 5-16), with multiple sub directories.
All the files placed in the sub directories of the directory named ‘Binaries’ are used in the AMT LION runtime environment. The root of the ‘Binaries’ folder is defined by the setting of the ‘Local Source folder’ of the generation set. The generation process creates the files for the objects in the appropriate directory.
An AMT LION component ‘Prod(uction) Installer’ can also be used to put new releases of applications into production, from the files created in the generation process. This is typically a System Administrator function and is explained in the System Administrator course.

### Forms
Each form generates two separate files, a ‘dll’, which contains all of the business rules of a form, and a ‘ctr’ file, which contains the screen representation.
The ‘dll’ files containing the business rules are created in the sub directory ‘Server’ of the ‘Binaries’ directory, (see Figure 5-16).


Figure 5-16: Runtime folders
The ‘ctr’ files holding the screen representation are created in the sub directory ‘ClientGUI’ of the ‘Binaries’ directory, (see Figure 5-17)



Figure 5-17: ClientGui folder

### Reports
Each report is generated as an executable file (‘exe’). These files are created in the sub directory ‘Reports’ of the ‘Binaries’ directory, (see Figure 5-18)



Figure 5-18: Reports folder
## Database Reorganization
When an application is generated for the first time, or a change is made to the database design, a reorganization of the database is required.



Generally, a reorganization of the database is required when …

- 17.1 a table or index is created or deleted
- 17.2 the name of a table or index changes
- 17.3 a field in a table is added, changed or deleted
- 17.4 a key is added, changed or removed from an index, or a condition to the index changes

### Reorganizing the database
Before a Reorganization is performed the application must not be running (see section 6 AMT Runtime Environment).  In the AMT Control Center, right-click on the application that requires a reorganization and select ‘Stop All Servers’.
It is not necessary to stop the batch and print services, but there should not be any active reports running for the application.
Use Windows Explorer to navigate to the AMT Reorganize program in the %AMTROOT%/AMTTools/Reorganize folder in the AMT installation.
Start the program AMTReorganize.exe by right-clicking it and choosing ‘Run As Administrator’ from its context menu.  The details on how to Reorganize an application database are explained during the AMT Generation and Deployment training, and details can be found in the online help manual.



# AMT Runtime Environment

## Configuration
The configuration of an example AMT runtime environment is presented in the Figure 6-1.



Figure 6-1: Runtime configuration

AMT applications run in a so called three tier network layout, and use a ‘thin client’ concept. All the components in the configuration of Figure 6-1 are scalable and can be active on one or more physical or virtual servers.

### First tier
The database of an application resides on the server where the database engine is running.
On this server, no part on the actual AMT product suite is running, this is a standard SQL database that needs no modifications or special configurations to serve data for the AMT environment.

### Second Tier
The second tier is made up of the AMT Application Server, the AMT Batch Controller, AMT File Controller, AMT Print Controller, and the AMT Reorganization service.
The AMT Control Center is also a part of the second tier.
The AMT Application Server runs all business rules of the forms. The physical execution of the form transactions, that end users request, takes place on the physical server where the AMT Application Server is running.
The AMT Batch Controller runs all the reports. All physical executions of report transactions take place on the physical server where the AMT Batch Controller is running.
The AMT Reorganization service takes care of database reorganizations. It is needed in situations where developers producing new releases of their applications where the database definition is changed, (see section 5.5 Database ).

### Third Tier
On the workstations of end users runs, the application’s screen interface runs. This is a very small program, (app.exe), and will run on any Windows PC.
The client piece of the AMT product suite can be installed on the end-users’ workstation, but it’s not required, the program can also be run from a Windows shortcut when it is located on a shared network drive.
The end user interface can also be web browser-based; no additional software needs to be installed on the user’s workstation.  All that is needed is the availability of a supported web browser.

## Running the Application

Once the AMT application is generated, and if required a Reorganization performed (see section 5.5 Database ), the AMT LION developer can run the application directly by double clicking the ‘app.exe’ file found in the ‘..\Binaries\ClientGUI’ directory, (see Figure 6-2).
This executable can also be setup as a shortcut. Ensure the application service is started otherwise the error message “Error connecting to server” is displayed.



Figure 6-2: Location of ‘app.exe’.


## Form Flow
### Form life cycle

Figure 6-3 shows the flow of a form cycle at runtime.  This diagram is important because, outside of events, all form execution follows this model.



Figure 6-3: AMT LION form cycle
### Form behavior
The form behavior shown in Figure 6-3 is dependent on which commands are used in the routine ‘process_main’ and the value of the system item ‘error’. The table below gives an overview of these commands.

Table 6-1: Form behavior

## AMT Screens Runtime Options

The menu bar of the AMT Screens provides for a number of options, (see Figure 6-4). Which options are available for the end-user and which information is shown in the heading and tab-sheets, is configured in the AMT Control Center.



Figure 6-4: AMT Screens


File
The ‘File’ menu contains two options, one to ‘Print Screen’, and the other to ‘Exit’ the application.

Edit
Options exist within ‘Edit that allow the typical edit menu style functions, ‘Cut’, ‘Copy’, ‘Paste’, ‘Select All’ and ‘Undo’.
Additional options are to ‘Copy screen to clipboard’ and also ‘Clear to the end’ any edit fields.
An option also exists to ‘Start Calculator’, which starts the Windows calculator. The option to ‘Paste Calculator Result’, allows for the pasting of the calculator result directly into a field in the application.

Select
The ‘Select’ menu contains an option to ‘Select Screen’. Clicking this option opens a dialog box to enter the next screen name, or to select the next screen from a list of screens. This list of screens is defined and controlled in the AMT Control Center.
An option also exists to select ‘Language’. This then presents a list of languages made available in the AMT Developer Studio, (see section 12.1.5 Languages).
A number of other options are then available to select a tab sheet from those that are already visible, (see Figure 6-4). The visibility of these tab sheets is controlled by security settings in the AMT Control Center.
The first option displays the current form and is used to recall the application tab sheet. The following options are looked at in more detail in the following sections: ‘RTQuery’ section 9.1, ‘Report Management’ section 17.2, Running a report in the runtime environment, ‘Start Report’ section 17.2.1 Start report tab sheet. The option ‘Report messages/Requests’ displays any messages from reports. The option ‘Users’ presents a view of the current active users.
The options ‘User help’ and ‘Show Hint’ display any help or hints coded against the forms or visual objects.


Macro
The Macro options allow for the recording, deleting, editing of a macro of keystrokes.

Options
The choices in the ‘Options’ menu, allows a user to personalize their runtime environment.
Clicking on ‘Local settings’ opens a dialog box for the User to be able to change how they see their version of the application. In this dialog box the user can change the text settings, graphical settings, and printer settings of their application.
The options ‘Send=+’ and ‘Send=Enter’ allow the user to select which key will transmit the details of the form.
The options ‘View tabsheets’ and ‘Hide tabsheets’, allow the user to decide if the tab sheets are visible or not.
The options ‘Get messages in statusbar’ and ‘Get messages in Dialog box’, allows the user to select how the messages from the application are received.
The option to ‘clear cache files’ allows the user to clear any application files that are cached.

About
This option opens a dialog box show the current application details, such as the version of AMT Developer Studio and connection information.


Exercise 4: Make the application run
# Creating the Database Schema’s of the Application

## Database Objects
The folder ‘Database’ in AMT Developer Studio allows for four different types of objects to be created:

Tables
Defines the structure of the database where data is stored

Indexes
Defines a sorting order for reading through the data of a table, efficiently, in a particular order

Stored Procedures
Allow for SQL commands and queries to be written and stored centrally

Views
Allow for SQL views to be written and used in table, cursor or free queries



Figure 7-1: Database objects

### Creating a new Table

To create a new table, right-click in the repository view on the folder ‘Tables’ and select ‘Insert Table’ from the context menu, (see Figure 7-2).



Figure 7-2: Create new table

The ‘Insert Table’ dialog box is displayed, (see Figure 7-3), enter the table name and description and click the ‘OK’ button.


Figure 7-3: Create new table dialog
The table is then created and the ‘Options’ section is presented, (see Figure 7-4).


Figure 7-4: Table options
The definition of ‘Filegroups/Tablespace’ allows SQL Server to divide the database into ‘Filegroups’ (Oracle uses the same concept, but calls it ‘Tablespaces’).
Using the ‘Add timestamp fields’ drop-down list box, you can specify whether the date and timestamp fields are added to the table. When set to ‘Default’, the setting is inherited from the Application options as described in section 12.1.
If the table contains data in Unicode format, the ‘Unicode’ setting should be changed to ‘Yes’.
For every table created, the field ‘LIONRECNO’ is automatically added, (see Figure 7-5). When it’s expected that the table will contain more than 999,999,999 records, the length of ‘LIONRECNO’ can be extended to 18 digits by altering the setting in the table options.

### AMT LION maintained fields
Every record inserted into a table gets a unique auto-incrementing (identity) integer in the ‘LIONRECNO’ field.  ‘LIONRECNO’ is used by the AMT Runtime environment, and is available as a readonly value to the developer in code.
The drop down listbox ‘Add timestamp fields’, (see Figure 7-4), when set to ‘Yes’ or ‘Default’, or set to ‘Yes’ at the application level (See section 12.1.1), creates four extra fields in a table, ‘LIONCREATEDDATE’, ‘LIONCREATEDTIME’, ‘LIONMODIFIEDDATE’ and ‘LIONMODIFIEDTIME’, (see Figure 7-5).
The AMT runtime environment automatically maintain the date and time stamps for each of these items when creating or modifying a record in the table.
These fields are available to the developer for reading, but not for updating.

### Defining fields in a table
To define fields in a table, choose ‘Fields’ from the navigation tree, (see Figure 7-5).


Figure 7-5: AMT LION fields

To insert a field in the table, right-click in the grid and select ‘Insert’ from the popup menu, or press the ‘insert’ key, (see Figure 7-5).

The field is added with a default name of ‘FIELD1’, (see Figure 7-6).

Figure 7-6: Adding a field
If creating a Boolean field, it’s worth noting that not all database suppliers provide the same implementation for Boolean fields in tables. For consistency reasons, fields defined in AMT Developer Studio as Booleans are stored in the database as a one alpha field with the value of ‘T’ or ‘F’. This implementation must be remembered when creating SQL queries that include these Boolean defined fields.
Although the character ‘-’ is allowed as part of a field name, it’s not recommended. The ‘-’ character is not supported in all databases and is translated by AMT to an underscore ‘_’, this can be confusing when looking at the database using database management software (e.g. SQL Server Management Studio).  This also must be remembered when creating queries outside of AMT.
The ‘Encrypted’ property allows for the data stored to be encrypted. Encryption can only be enabled for alphanumeric fields and when these fields are not part of an index.
If the ‘Identity’ property is set to ‘Y’, then that field will replace LIONRECNO as the unique identifier. Only one field can be set to ‘Identity’ in a table.
When a new field is added to an existing table, and is not part of an index, during reorganization, (see section 5.5 Database ), the new field is initialized with the value NULL in any existing records of the table. This must be remembered if creating SQL queries that include new fields added to an existing table.
The Object Inspector also allows for maintenance of existing fields, but be aware that changing an existing field’s name or attributes removes any existing data in the field. This occurs for the entire table when renaming the table.
Repeat the insert process to add more fields, or use ‘Bulk Mode’, (see section 7.1.5).

### Deleting fields from a Table
To delete fields from a table, either select the field and right-click on it and select ‘Delete’ from the popup menu, (see Figure 7-5). Alternatively, enter ‘Bulk Mode’, (see the following section), and delete the field(s) from there.
The system field ‘LIONRECNO’ cannot be deleted.

### Bulk mode
‘Bulk mode’ allows for a number of fields to be entered into a table, or for the quick editing of fields.
To enter fields in bulk mode, right-click in the grid, and select ‘Bulk Mode’ from the popup menu, (see Figure 7-5).
This opens ‘Bulk Mode’, which is a quick text editor similar to Windows Notepad, (see Figure 7-7). Cut, copy, paste and find and replace are allowed within ‘Bulk Mode’.



Figure 7-7: Bulk mode

When the ‘OK’ button is clicked, the AMT Developer Studio validates the field definitions.
Any errors are highlighted in an ‘Error’ dialog box, (see Figure 7-8). If the validation is successful, then the changes are applied and control is returned to the table view seen in Figure 7-9: Fields added.



Figure 7-8: Error in field definition


Figure 7-9: Fields added

### Indexes
Indexes define a sort order for speeding up data access when reading through the data of a table in a particular order.
It is also possible to define conditions/filters on an index, so that only particular records are retrieved. This also speeds up the data retrieval from the database.
An index must always belong to a table; it’s not possible for an index to exist without a table.
A table can have many indexes defined, or even no developer defined indexes at all. AMT LION automatically create one index on a table in LIONRECNO order.
Although indexes might appear to be defined in the table object, they are objects in their own right, and are displayed as such in the AMT Developer Studio repository view.

#### Creating an Index
To create an Index on a table, within the table itself, select ‘Indexes’ from the left-hand navigation, and click ‘Add new index’, (see Figure 7-10).


Figure 7-10: Create an index

The window to define the index is then displayed, (see Figure 7-11). The ‘Name’ and ‘Description’ of the index can be entered here.


Figure 7-11: Index configuration
As described earlier in section 7.1.1, the option ‘Filegroup/Tablespace’ is used when a SQL/Oracle database that is divided into ‘Filegroups/Tablespaces’.
The “Use default fill factor” option, if checked, defaults to use the value specified in the application’s Global Options. If unchecked, then the fill factor for the index will be the value specified in the edit box. This is something that is typically determined by a Database Administrator, but the value chosen is dependent on the number of records to be added or changed in the table. A static table results in a large fill factor (e.g. ‘100’, whereas a table where a great deal of changes/additions are being made results in a low fill factor (e.g. ‘60’).



The option “Unique Index”, if checked, ensures that records with exactly the same keys cannot be added to the table. If this is attempted, it results in a database error.
If the option ‘Set as Primary Key’ is checked, then the index is set as the primary key. This is something that is normally determined by a Database Analyst, but setting an index as primary key can enhance the performance of data access if the index is the one that is primarily used against a table, and the table is relatively static.
Only one primary key can be defined per table. Primary key fields are automatically set as a unique index, and as such do not allow key fields to have NULL values.
To add keys to the index, use the drop-down list boxes to select fields, and the corresponding order, ascending (‘ASC’) or descending (‘DSC’), (see Figure 7-12).


Figure 7-12: Enter keys
In the section ‘Include Extra Columns’, fields can be added that will be included when data is retrieved with ‘KEYONLY’.
‘Conditions’ allow for the entry of a condition/filter on the index, (see Figure 7-12). Using conditions enables the index to only retrieve records out of the database that meet the condition. At generation, an extra field in the format ‘FLAG_<indexname>’ is automatically created in the database, to indicate if a record belongs to the index.
Allowed operators for conditions are, ‘=’, ‘<’, ‘>’, ‘<>’, ‘and’, and ‘or’.
Parenthesis can be used to avoid creating unclear conditions when mixing the ‘and’ operator with the ‘or’ operator in conditions.

Using fieldnames from the table on the right side of the condition is allowed.

Example syntax of unclear mixed ‘and’ and ‘or’ conditions:
mailing = 'Y' and cust_no > 0 or name <> ''
mailing = 'Y' and name <> '' and address <> '' or cust_no > 0


Example syntax of clear conditions, using parenthesis:
mailing = 'Y' and (cust_no > 0 or name <> '')
mailing = 'Y' and ((name <> '' and address <> '') or (cust_no > 0))

The retrieval of records is much quicker with a condition; however, it does restrict the generic use of an index, and should be used cautiously. An alternative to placing a condition on the index is to use a ‘where clause’ when reading the data from the database. This can work out just as efficiently and allows generic use of the index, (see section 8 Data Access in the Application).

#### Saving and using Tables and Indexes
Tables and Indexes are saved and validated in the same way as Forms (i.e. by using the save speed buttons, and/or the shortcut key ‘F7’).
Before tables and indexes can be used in other objects they must first be ‘checked in’. The next section ‘Checking in Objects’ explains the check-in procedure, but remember, tables and indexes are two separate objects in the AMT Developer Studio repository, and they both must be checked in. Checking in a table does not automatically check in the index(s), and vice-versa.
Once the tables and indexes are checked in, program code in forms, reports and global routines can be written to access and update the table(s).
## Checking in Objects
Up until now little has been said about checking in objects, because Forms and their code can be generated in edit. This is not the case for Database Schema’s. They must be checked in before they can be used in the code of Forms or Reports.
When creating a new object, it is automatically assigned a revision of ‘1.0’. This can be seen in both the repository view and in the ‘Revision’ window. To access the Revision window, enter ‘REV’ in the open command box, (see Figure 7-13).



Figure 7-13: Locked objects

Revisions are covered in more detail in section 15 Application management, but for now just checking in an object is discussed.
The tab sheets group the particular objects into their relevant categories. For example, to check in a table the top tab sheet ‘Database’ must be selected, and then the sub tab sheet ‘Tables’, (see Figure 7-13).
The object is automatically locked to the developer that created it. This is displayed in the ‘Locker’ column in both the repository and revision view, (see Figure 7-13). This ensures that the object is only available for modification by that developer. Objects that are locked can be viewed by other developers, but not changed.

To check in an object, select the object to be to be checked in by clicking on it, or select multiple objects by the standard Windows method of using the ‘SHIFT’ or ‘CTRL’ keys and clicking the objects to be checked in. Once the object(s) are selected click the ‘Check in’ button.
The ‘Revision comment’ dialog box is displayed.



Figure 7-14: Revision dialog

The object being checked in is automatically assigned a higher revision. Another revision number can be used, as long as it is higher than the current one. For example, in Figure 7-14 the developer may decide on a new revision of 2.0, instead of 1.1.
A ‘Revision comment’ must be entered.

Once the ‘Ok’ button is clicked, the object is checked in, and the repository view is returned, (see Figure 7-15).


Figure 7-15: Object checked in

In the revision view, (see Figure 7-15), the object is no longer shown as locked, both by the ‘Locker’ column being empty, and also by the object no longer being displayed in red.
The ‘Revision’ column also now shows the most recently checked in revision. Any other developer can now freely view and lock this object.


Exercise 5: Create tables, indexes and check-in code

# Data Access in the Application
A number of methods exist within AMT LION to access data. A Table Query is the most efficient of these, but it is also possible to perform (stand-alone) free queries against the database, and to create stored procedures and views. Also, in order to support data access methods that existed in COBOL legacy systems cursor queries are available.
The following section looks at the most important functions used in data access.

## Table Query
A table query defines a buffer for data between the database and the program code. A variable type, known as a ‘tablequery’, is declared in the ‘var’ section of ‘Definitions’, (see Figure 8-1).



Figure 8-1: Table query


A table query uses the following construct:



Figure 8-2: Table query syntax

As seen in Figure 8-1 and Figure 8-2, the application name is optional, and is only required when the data being retrieved is from a table defined in a different application to the one where the object table query is defined. This ‘application link’ would also need setting up in the AMT Control Center by a AMT System Administrator.
Generally, it is sufficient to define just one table query variable per table to be accessed, in an object.  However, developers may define as many table queries per table as they feel are needed, as can be seen in the example syntax. This is particularly useful if more than one record of the same table needs to be read simultaneously into memory.
Example syntax:
var
tq_customer1 : tablequery (t_customer)
tq_customer2 : tablequery (t_customer)
tq_customer3 : tablequery (t_customer)

As well as a table query variable being used in program code to store retrieved records from the database, it can also be used as a buffer to store new records before inserting them in the database table. In the following example syntax ‘tq_customer’ is used to inquire on the table and store the table data, and ‘ti_customer’ is used as a store for new records to insert into the table.
Example syntax:
var
tq_customer : tablequery (t_customer)
ti_customer : tablequery (t_customer)


### Table query read
To read records from the database table with the ‘tablequery’ variable defined in the definitions section, a number of functions and function parameter(s) need to be defined.
These functions and their parameters result in several lines of program code, as can be seen with the code lines 223 to 225 in Figure 8-3.



Figure 8-3: Table query example

These functions and their parameters specify the index to use when retrieving the data, the keys of the index, and the method of retrieving the data.
It is the specification of the retrieval method that actually executes the query, and retrieves the data from the database, which is then placed in the table query control’s buffer.

### Specifying the index
Reading a table always begins with the function to define which index to use, (see code line 223 in Figure 8-3). If no index is specified, then AMT will use the automatically generated system index, which retrieves the records in ‘Lionrecno’ order. This is generally the order in which the records were added to the database table.
Generally, the construct of specifying the index is as follows:



Figure 8-4: Using index syntax

Example syntax 1:
tq_customer.index (idx_custno)   //Cust number order

Example syntax 2:
tq_customer.index ()		   //Retrieved in Lionrecno order


### Specifying the index keys
Once an index is defined then the next function line is generally the definition of the keys on the index, (see code line 224 in Figure 8-3).
When defining the keys, all of the index keys must be defined. If no keys are specified at all, then the records will be retrieved from the first record on the table in the order of the index specified.
Generally, the construct of specifying the keys is as follows:



Figure 8-5: Using index keys

There are two functions available when specifying the keys. These are ‘Equal’ and ‘Start’.
The total number of keys in ‘Equal’ and ‘Start’ must match the number of keys in the index.


Equal
The ‘Equal’ function retrieves only records that are equal to the specified key(s). In the example syntax below, (which still requires a retrieval method), only records where the name and postcode are equal to an (as yet undefined) key value will be retrieved.
Example syntax:
tq_customer.index (idx_name)
tq_customer.equal (name, postcode)


Start
The ‘Start’ function defines the starting point from which the records are retrieved from the table. In the example syntax below, (which still requires a retrieval method), records will be retrieved from the key values in ‘name’ and ‘postcode’.
Example syntax:
tq_customer.index (idx_name)
tq_customer.start (name, postcode)


The ‘Start’ function can also be used in conjunction with an additional operator ‘desc’, which starts the retrieval of records from the index in reverse order, as seen in the example syntax below, (which still requires a retrieval method).
Example syntax:
tq_customer.index (idx_name)
tq_customer.start desc (name, postcode)



Equal and Start
‘Equal’ and ‘Start’ can also be used together. The specification of the keys is then constructed over two lines, as seen in the example syntax below, (which still requires a retrieval method.
Example syntax:
tq_customer.index (idx_name)
tq_customer.equal (name)
tq_customer.start ('')


### Retrieval method
The final function to be coded is the retrieval method. It is this statement that actually executes the table query and retrieves the data from the database, and then places it into the tablequery buffer. Two functions exist to specify the retrieval method: ‘getfirst’, and ‘loop’ with an ‘endloop’.
In both instances, a boolean system variable named ‘resok’, when one or more records is retrieved, is set to true and when no records are retrieved, it is set to false. This system variable can be checked to ensure that data is retrieved. The section 4.1.2.1 Resok explains other instances when resok is set.

Getfirst
The ‘getfirst’ function retrieves only the first record (based on indexing and filtering) from the table and places the data in the ‘tablequery’ variable defined. If ‘getfirst’ is used with an equal then it will retrieve the first record that is equal to that key, and if used with a ‘start’ it will retrieve the first record from the start point specified, which may also be equal to the key values if such a record exists.
Example syntax:
tq_customer.index (idx_custno)
tq_customer.equal (cust_no)
tq_customer.getfirst ()
if resok
validate-customer ()
else
sme ('Error', 'Customer record not found')
endif


Loop Endloop
The ‘loop endloop’ creates a loop that retrieves data sequentially using the index specified, one record at a time into the ‘tablequery’ variable’s buffer, on each occurrence of the loop. This loop continues as long as a record can be retrieved from the database, that matches the conditions of the read, or a break is encountered.

The conditions of the read are only evaluated at the start of the read process, and not at every occurrence of the loop.
Example syntax:
tq_customer.index (idx_name)
tq_customer.equal (name)
tq_customer.start ('')
loop tq_customer
validate-postcode ()
endloop
if not resok
sme ('Error', 'Customer record not found')
endif

Find (First) and Find (Next)
A third retrieval method may be encountered from older migrations to AMT LION. This method was first used to migrate data retrieval methods used in COBOL.
This type of retrieval method can still be used with a table query, but cursor queries have greater functionality for this type of retrieval method, (see section 8.3 Cursor queries).

### Where clause
The records that are retrieved from the database can also be filtered with a ‘where’ clause. This is especially useful in writing efficient code, as it minimizes the number of records that the database engine can return to the application.
Unlike the ‘equal’ and ‘start’ functions that can only use the keys of the index, a ‘where’ clause can use any field in the table as a condition.
In a ‘where’ clause the left element of the condition must always be a database field, and the clause must always be a comparison - a single boolean database item cannot be used on its own.
Example syntax:
tq_customer.index (idx_custno)
tq_customer.start (0)
tq_customer.where (tq_customer.mailing = 'Y')
loop tq_customer
send-mail ()
endloop

The ‘where’ clause can use a number of different operators and SQL type functions (e.g. ‘like’, ‘in’, ‘left’, ‘right, ‘substring’, upper, lower, etc).

### Locking records
There are two methods of locking records, so that the record cannot be updated by a concurrent program, or transaction. One method is to use the ‘locked’ option on the index, and the other is the ‘locked’ function. Both of these methods lock the records until the end of the current transaction.
A form transaction is the time from when the user transmits, or clicks a button, to the time the screen is returned back to the user. For a report this is the time from the start of the report until the completion of the report.
To avoid loss of performance, or possible occurrences of deadlock situations, the lock can be released before the end of the transaction with a ‘commit’ or “saverecoveryname’, (abbreviated to ‘srn’), command, (see section 16.7.6 Saverecoveryname).
When a deadlock or timeout situation occurs, a bugreport is written to the application’s log folder. This log can help the developer in solving the lock issue.
The ‘locked’ option on the index locks the records while being read by the index and table query. Any subsequent table query reads, using the same ‘tablequery’ variable, does not lock records.
Example syntax:
tq_customer.index (idx_custno, locked)
tq_customer.start (0)
loop tq_customer
update-customer ()
endloop

The locked function locks the records in a table query, and is different from the locked option on an index, as it locks records for any subsequent reads using the same ‘tablequery’ variable.
Example syntax:
tq_customer.index (idx_custno)
tq_customer.equal (cust_no)
tq_customer.locked ()
tq_customer.getfirst ()
if resok
update-customer ()
endif

### Resultokto
The function ‘resultokto’ directs the result status from resok to a specified boolean, or alphanumeric, (length 5), variable.
Example syntax
tq_customer.resultokto (vb-custok)

### Retainptr
When the ‘retainptr’ is set to true, the specified table query retains its pointer position.  When this table query is again read, it executes from the next record of the table query. This pointer is initialized at the start of any transaction.

Example Syntax
tq_customer.retainptr (true)

## Free Query
Like a table query, a free query can be seen as a buffer between the program code and the database. While the table query is a variable that is always related to a specific table, the free query is a variable that is not specifically related to any table.
This free query can be used to perform any data access that the ANSI SQL syntax allows.
Declaration of this variable is similar to a table query, but only the type declaration ‘query’ is needed.
Example syntax:
var
fq_cust : query

The free query can now be used to retrieve data from the database, as well as perform inserts, updates or deletes in the database.
If the retrieval of the data is required in an order where a table query index does not exist, and the retrieval order is different to that of Lionrecno, then a free query can be more efficient than a table query. Another factor, when considering a free query, is the available query complexity a free query allows.
With a free query, it’s possible to make use of inner and outer joins which can be a powerful tool when data is required from more than one table.
The way to use this variable type is by setting its properties and calling its methods, in a similar way to the table query.

### Specifying the database
The first property to set is the ‘database’. If this property is not specified (or is set to blank), the database that belongs to the Application itself is used. External databases can be accessed, but these need to be defined by a System Administrator in the AMT Control Center.
Example syntax:
fq_cust.database := ''


### Writing the query
The free query statement is defined in the ‘sql’ function of the free query.
A free query statement must be compliant with the syntax that the database engine is using (no syntax checking for SQL in free queries is performed in the AMT Developer Studio). Best practice is to test the free query SQL in an editor that can execute SQL statements to avoid runtime errors (e.g. RTQuery, see section 9.1 RTQuery, SQL Server Management Studio, etc).
Example syntax:
fq_cust.sql := 'SELECT CUST_NO, NAME FROM T_CUSTOMER'

When the specification of a table is changed the objects that have a free query against this table are not automatically checked/changed in the syntax (as is done with a tablequery). The free query is a freely formatted string, thus impossible to syntax check at validation time.
It’s good practice to check for any errors after executing a free query. For this, the system variable ‘GETLASTRESULT’ can be used.

### Executing the free query statement
The free query is executed in a similar way to a table query. Once a ‘loop <query name>’, or <query name>.execsql command is encountered, the free query is executed.
The values from the database are copied into one of the specified variables, ‘asNumeric’, ‘asInteger’, or ‘asString’, depending on the type of data.
In the following example, the field ‘CUST_NO’ is copied into the free query’s ‘asNumeric’ variable, and the field ‘NAME’ is copied into the free query’s variable ‘asString’. These are both then assigned to their respective display fields.
Example syntax:
fq_cust.database := ''
fq_cust.sql := 'SELECT CUST_NO, NAME FROM T_CUSTOMER'
loop fq_cust
cust_no := fq_cust.asNumeric ('CUST_NO')
name    := fq_cust.asString ('NAME')
endloop

Other SQL statements, such as updates, can also be performed with free queries against the database, but use with caution when using these types of statements mixed with user entered data.
Example syntax:
fq_cust.database := ''
fq_cust.sql := 'UPDATE T_CUSTOMER SET MAILING = ''Y''
fq_cust.sql &= 'WHERE CUST_NO = 12345678'
fq_cust.execsql ()
## Cursor queries
Cursor queries are used to access the database in a Unisys DMS II way, and are used when converting Unisys COBOL code.
The use of cursor queries is only supported where the application option ‘add Lionrecno as last key to not unique indexes’ is set, (see section 12.1 Global Options.
Cursor queries are less efficient than table queries, and should only be used when a table query, or free query, cannot be used. The following section is an overview of cursor queries.



Cursor queries, like table queries, must be defined in the ‘var’ section of ‘Definitions’; and follow a similar construct.



Figure 8-6: Cursor query syntax

Example syntax :
var
cq_customer : cursorquery (t_customer)

At runtime a cursor query retains one cursor position per table index, (including the lionrecno index). The cursor is always set to a logical position, which means that the position is a virtual one. In fact, the cursor position can be set at a record (row), just before the first record, between two consecutive records, and after the last record. There is no physical relation with a specific record.
Initially the cursor is set to the virtual position prior to the index's first record. After a query function is executed, the current cursor position is maintained and used as the starting point for the next retrieval.
Because the cursor is set virtually, it remains at its logical position even if the query function did not return a record.


For example, if no record is returned on a Cursor Query read, the virtual position of the cursor is set before the record with the next higher key (logically depending on the sort order). If the sort order for the index is descending the cursor will be set to the logical position before the record with the next lower key. Because of this, a ‘findnext’ function continue from the record that is read when the ‘findfirst’ was executed. This behavior differs from a table query or free query, where if no record is found it is impossible to search further.
In specific situations when a Cursor Query cannot be executed, the system item ‘resok’ is set to false, and a system item ‘si-dbstatus’ is filled with a number indicating the cause, (see section 12.1.1 Options).

### Cursor query functions

The following are the most commonly used cursor query functions.

Cursor query functions follow a similar construct to table queries.



Figure 8-7: Cursor query function syntax
#### Findfirst
The ‘findfirst’ function retrieves the first record irrespective of the current cursor position.
If a ‘where’ clause is specified immediately prior to the ‘findfirst’, then it will retrieve the first record corresponding with the ‘where’ clause, based on the index specified.
If no record is found then the cursor is set to a virtual location preceding the record with the next higher key, or in the case that no higher key can be found, to the position after the end of the table. If the cursor is positioned after the end of the table, then a ‘findnext’ results in ‘resok’ being set to false, and a ‘findprior’ will return the last logical record for the index.
Example syntax:
cq_customer.where (cq_customer.mailing = 'Y')
cq_customer.findfirst (idx_custno)


#### Findnext
The ‘findnext’ function retrieves the next record based on the current cursor position.
If a ‘findnext’ is immediately preceded by a ‘where’ instruction, then the next record that corresponds with the ‘where’ condition based on the current index, is retrieved, using the current cursor position as a starting point.
If the ‘findnext’ is not directly preceded by a ‘where’ instruction, then the record after the current cursor position is retrieved, based on the current index.
Example syntax:
cq_customer.findnext (idx_custno)

#### Findprior
Using ‘findprior’ retrieves the previous record based on the current cursor position.
If ‘findprior’ is immediately preceded by a ‘where’ instruction, the previous record for the current index that corresponds with the ‘where’ condition is retrieved, starting from the current cursor position.
If the ‘findprior’ is not directly preceded by a ‘where’ instruction, then the record before the current cursor position is retrieved, based on the current index.
Example syntax:
cq_customer.findprior (idx_custno)

#### Findlast
The function ‘findlast’ retrieves the last record irrespective of the current cursor position.
If a ‘where’ clause is specified immediately prior to the ‘findlast’ the last record for the specified index that corresponds with the ‘where’ condition is retrieved.
If ‘findlast’ is not directly preceded by a ‘where’ function, the last record based on the index is retrieved.
If no record is found, the cursor position is set before the beginning of the table, so that ‘findnext’ returns the first record in the table.
Example Syntax:
cq_customer.where (cq_customer.cust-no > 500000)
cq_customer.findlast (idx_custno)


#### Findcurrent
Using ‘findcurrent’ re-reads the current record into the cursor query variable.
Example syntax:
cq_customer.findcurrent (idx_custno)

#### Where
A ‘where’ clause filters the records retrieved from the database. The ‘where’ clause must be specified directly before any specified find function.
Like the table query’s ‘where’ clause, the number of records that the database engine returns to the application at runtime is minimized, increasing the response time of the application.
Example syntax:
cq_customer.where (cq_customer.mailing = 'Y')
cq_customer.findfirst (idx_custno)
## Referencing Records Retrieved from a Table/Cursor Query
The table query and cursor query inherit the construct of the specified table, and automatically contain the same fields as the table. To reference the data in these fields, type the table/cursor query name followed a period and type the field name, or select it from code completion list that appears.
Example syntax:
tq_customer.cust-no

### Assigning values to table/cursor query fields.
Assigning values to table/cursor query fields is the same as explained in the section 4.2.2 Assigning values.
Example syntax:
if button_action = 'A'
ti_customer.city      := city
ti_customer.country   := country
ti_customer.cust-no   := cust_no
ti_customer.cust-type := radio_cust_type
ti_customer.name      := name
ti_customer.mailing   := checkbox_mail
ti_customer.postcode  := postcode
ti_customer.street    := street
endif

Using this example syntax, it’s important to note that often program code requires a series of similar assignments.  This is where the block assign can help, (see the following section).


### Block assigning
It is possible to assign multiple fields of an object, to equally named fields in another object, in a single assignment by using the asterisk character (e.g. ‘*’).
The source object and target object do not have to be of the same type. It is possible (see example syntax below) to fill the table query fields, of the target object, with field values from a source object such as a form screen layout. The following object types can be used in block assignments, either as a source or target.

- 27.1 A table/cursor query
- 27.2 A form screen layout
- 27.3 A report layout
- 27.4 A file layout
- 27.5 A variable structure

All of the field names in both objects need not match. Only the values from fields with matching names in the source object are assigned to the fields, with the same name, in the target object. So, if there are fields in the target object that do not exist in the source object, or are differently named, then these target fields keep their current value, and must be separately assigned after the block assign command, if required.

Example syntax:
if button_action = 'A'
ti_customer.*         := customer.*
ti_customer.mailing   := checkbox_mail
ti_customer.cust-no   := cust_no
ti_customer.cust-type := radio_cust_type
endif

When using block assignment it is not possible to use the ‘with’ construct, (see section 12.4.1 With … Endwith).

### Inserting a record
To create a new record in a table, use the function ‘insert’. Values must first be assigned to a table query buffer before the function ‘insert’ is called.
Example syntax:
if button_action = 'A'
ti_customer.*         := customer.*
ti_customer.mailing   := checkbox_mail
ti_customer.cust-no   := cust_no
ti_customer.cust-type := radio_cust_type
ti_customer.insert ()
endif

When executing multiple inserts in a table and using the same table query variable, use the function ‘clear’ if wanting to make sure that no values from a previous insert action are re-used in the next insert.
Example syntax:
if button_action = 'A'
loop for int-loop := 1 to 10
get-cust-details ()
ti_customer.clear ()
ti_customer.city      := va-city
ti_customer.country   := va-country
ti_customer.cust-no   := vn-cust-no
ti_customer.cust-type := va-cust_type
ti_customer.name      := va-name
ti_customer.mailing   := va-mail
ti_customer.postcode  := va-postcode
ti_customer.street    := va-street
ti_customer.insert ()
endloop
endif

It is also possible to use the insert function to create a record in the table from one table query buffer space and assign the values to another table query buffer space. Optionally the initial table query can also be cleared within the same command.
Example syntax:
if button_action = 'A'
ti_customer.*         := customer.*
ti_customer.mailing   := checkbox_mail
ti_customer.cust-no   := cust_no
ti_customer.cust-type := radio_cust_type
ti_customer.insert (tq_customer, clear)
endif


### Updating a record
To update a record, the record must first be read from the database to a table/cursor query. The values that are to be updated must be assigned to the table/cursor query buffer before the method ‘update’ is called.
Using an asterisk in the ‘update’ function updates all the fields of the table. In the example below the address details are changed, but all of the fields are updated on the customer record.  Any unchanged fields in the table/cursor query retain their value from the original table/cursor query read, as long as, they were not cleared.
Example syntax:
if button_action = 'C'
tq_customer.index (idx_custno)
tq_customer.equal (cust_no)
tq_customer.getfirst ()
if resok
tq_customer.street   := street
tq_customer.city     := city
tq_customer.postcode := postcode
tq_customer.country  := country
tq_customer.update (*)
endif
endif

Specifying fields in the ‘update’ function only updates the specified fields of the table in the database. In the example below, only the street, and postcode are changed.
Example syntax:
if button_action = 'C'
tq_customer.index (idx_custno)
tq_customer.equal (cust_no)
tq_customer.getfirst ()
if resok
tq_customer.street   := street
tq_customer.postcode := postcode
tq_customer.update (street, postcode)
endif
endif

### Deleting a record
To delete a record, the record must first be read from the database with a table/cursor query.  Once the ‘delete’ function is called the record is physically deleted from the database. Use this method with care, as there is no simple way to restore the record once deleted.
Example syntax:
if button_action = 'D'
tq_customer.index (idx_custno)
tq_customer.equal (cust_no)
tq_customer.getfirst ()
if resok
tq_customer.delete ()
endif
endif

## Code Editor Advanced
### The Code Wizard
As previously covered, a code wizard is available in the AMT Developer Studio, (see Figure 8-8). The code wizard can be especially useful when creating code to read and maintain data.
To start the code wizard, click in the code editor where the code is to be inserted, then either right-click and select ‘Code Wizard’ from the popup menu, (see Figure 4-8), or use the shortcut keys ‘CTRL’ + ‘W’.



Figure 8-8: Code wizard
The popup is only shown when the object is in edit mode.

#### Insert statement
The first option of the code wizard is the 'Insert statement', (see Figure 8-8). This creates the program code to insert a record into a table.
After clicking the ‘Insert statement’ button, all available table queries and tables are shown, (see Figure 8-9).


Figure 8-9: Code wizard ‘insert’
Select the required ‘Table Query’ and click the ‘Finish’ button, (see Figure 8-9), all fields of the related table are added in the code editor, together with the insert command, at the position where the screen cursor was when the code wizard was started, (see Figure 8-10). All that now needs adding are the values to be assigned.

Figure 8-10: ‘Insert’ code inserted
#### Select statement
The second option in the Code Wizard, ‘Select statement’ (see Figure 8-8), enables a developer to create a block of program code to read records from the database.
After clicking the ‘Select statement’ button, all available table queries are displayed, (see Figure 8-11).


Figure 8-11: Code wizard Table query select dialog


The locally defined, and any globally defined (described further in section 12.1.15), table queries of the current object are shown.
It is possible to filter this view to just the table queries locally defined in this object by clicking the ‘Show only used table queries in this object’ radio button, (see Figure 8-11).

After selecting the required table query, click the ‘Next’ button. A list of indexes for the table, index keys, and options for the retrieval methods is then displayed, (see Figure 8-12).



Figure 8-12: Select table fields

The index to use is selected from the list, and the retrieval method is defined in the lower section of the dialog box, (see Figure 8-12).
The ‘Keys in the equal part’ selector defines the number of keys to be used in the equal function of the read. If not all the keys are selected, then the remaining keys are automatically assigned to the ‘start’ function.
‘Read Locked from now’, if checked, assigns the lock function to the table query.
The option ‘Read reversed order’, if checked, places the ‘desc’ command in the read function, to read backwards through the index.
If the option ‘Read first record only’ is checked the command ‘getfirst’ is inserted, otherwise, the ‘loop endloop’ construct is created as the retrieval method.
The option ‘Isolation level Read Committed’ can be checked when this table needs to be read using “Read Committed” isolation mode. The default isolation level is set in the AMT Control Center at installation time. The setting is typically set to “Read Uncommitted” which is the default for Unisys A-series DMSII databases.
Once the retrieval method is determined, click the ‘Finish’ button.

The code lines are automatically inserted in the code editor at the position where the screen cursor is located when the code wizard started. In Figure 8-13, the option ‘Read only the first record’ was selected when defining the retrieval method.


Figure 8-13: Query statement inserted

Now all that needs defining are the values for the the keys in the table query being read.


#### Update statement
The fourth option in the Code Wizard is the 'Update statement', (see Figure 8-8). This creates the program code to update an existing record of a table.
After clicking the ‘Update statement’ button, all available table queries and tables are shown, as seen in Figure 8-11.
After selecting the required ‘Table Query’ and clicking the ‘Next’ button, (see Figure 8-11), the fields of the table are listed for selection, (see Figure 8-14).



Figure 8-14: Code wizard ‘update’

The fields can be individually selected by checking the required check boxes, or the ‘Select all’ button to select all the fields. Once the fields are selected, click the ‘Finish’ button.
When only some of the fields are selected then only the selected fields of the table are added in the code editor, together with the update command for those fields. The code is inserted at the position where the screen cursor is located when the Code Wizard started, (see Figure 8-15).
All that now needs adding are the values to be assigned.



Figure 8-15: ‘update’ statement inserted

When all fields are selected for the update they are added in the code editor ready for values to be assigned, but the update command contains an asterisk to update all the fields (e.g. tq_customer.update (*)).

#### Print layout items
The fifth option of the code wizard is the 'Print layout items’, (see Figure 8-8). This creates program code that lists all the fields of a form, and when used in a report, lists all the layout items of the selected layout.
After clicking the ‘Print layout items’ button, (see Figure 8-8), a dialog box is presented, (see Figure 8-16).



Figure 8-16: Code wizard ‘Print layout’

Labels can be excluded from the list of form items by selecting the ‘Labels excluded’ option.

Clicking the ‘Next’ button presents a list of all the form items, (see Figure 8-17). The fields can then be individually selected, or the button ‘Select all’ used to select all the fields. Once the fields are selected, click the ‘Finish’ button.


Figure 8-17: Code wizard ‘Layout items’ selected

This then adds the form items into the code editor ready for values to be assigned, or for the form items to be assigned elsewhere. In Figure 8-18, the ‘File Layout Items’ (See section 8.5.1.6 File layout items) option are selected, so that the form items are listed ready for values to be assigned.


Figure 8-18: Layout items inserted

#### File layout items
Choosing the option ‘File layout items’, (see Figure 8-8), adds the form items to the code editor ready for values to be assigned. The option ‘Read layout’, adds the form items to the code editor for them to be assigned elsewhere. The dialog presented is similar to the ‘Print Layout Items’.
#### Auto completion
AMT Developer Studio provides an auto completion function when typing data access program code.
In the popup that appears after the period key is pressed, all properties, methods, functions, and fields of the table/cursor query or free query are presented for easy selection, (see Figure 8-19).



Figure 8-19: Auto completion example

Clicking the required item from the list places that item automatically in the code editor.


#### Popup menu help
Right-clicking on code lines displays context-sensitive help. For example, right-clicking on an index name presents a popup, displaying useful information about the table and the index, (see Figure 8-20).



Figure 8-20: Content sensitive help

Right-clicking on item names also displays useful information about the attributes of the item.

## Database Issues
Most common issues are:
- 29.1 Lock time out
- 29.2 Deadlock
### Lock time out
A lock time out is caused by another process locking the record(s) that need to be locked by the process that fails. When this happens, a bug report of the failing process is generated. The bug report gives information about the other process.
When the problem cannot be resolved by changing the programming code, the problem can be resolved by increasing the lock time-out or by running the programs in sequence.

### Deadlock
A deadlock occurs when two processes want to lock the same tables/records but in a different order (e.g. process A wants to lock tables X and Y, and process B wants to lock table Y and X). When both processes start at the same time, the situation can occur that process A locks table X and process B locks table Y. Both processes want to lock the next table but have to wait on the other process to release the lock. This is also called a deadly embrace. The database engine ultimately terminates one of the processes. This process is called the deadlock victim. A bug report is created for the failing process.
The bug report shows the failing statement:
exception message : DB: Transaction (Process ID 493) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction. [table:CPSEQ]
The bug report also shows the ‘LOCK REPORT’. This section shows the current locks at the moment of deadlock.
A deadlock cannot be resolved by increasing the lock time-out. The only way to solve this is to correct the programming code and lock the tables in the same order. If that is not possible, then it’s best to prevent both programs from executing concurrently (e.g. by putting the programs in a queue with ‘concurrent’ set to 1).

Exercise 6: Create code for table queries



# Data Inquiry and Maintenance in the Runtime
## RTQuery
In AMT Screens, on separate tab sheet, there is a tool named RTQuery. RTQuery allows for the inquiry and maintenance of database records, (see Figure 9-1). The visibility and use of this tool is controlled by using security settings in the AMT Control Center.


Figure 9-1: RTQuery tab sheet

### Table inquiry
Selecting the ‘Table’ option, allows for a database table to be selected from the ‘Table’ drop down list. Once a table is selected the records of that table are immediately displayed in the window below, (see Figure 9-1).
The records are ordered on the first index. If other indexes exist, then they can be selected from the ‘Index’ drop down list, thus changing the order of the records displayed to that of the selected index.
By default, the order of the Index is ‘Ascending’. By changing the ‘Order’ option to ‘Descending’, the data records are then presented in the window in descending order through the index.

### SQL queries
Selecting the option ‘Query’ allows for a SQL query statement to be entered in the upper section, to retrieve the records, (see Figure 9-2).



Figure 9-2: SQL query

### RTQuery command buttons
Run Query
The ‘Run Query’ command button allows for the running of the SQL statement entered. Using the shortcut keys ‘ALT’ + ‘R’ also runs the query.

Get More Data
The AMT Control Center has a setting to restrict the number of records retrieved when running a query.
If this value is exceeded then the records retrieved are displayed. The ‘Get more data’ button is then enabled, and if clicked, the query continues to retrieve records until the figure is again exceeded.  When all of the records are retrieved, they are displayed, and the query is complete.

Save SQL-File
The ‘Save SQL-file’ button allows for the SQL statement to be saved to a file.

Open SQL-File
The ‘Open SQL-file’ button allows for a previously saved SQL statement to be retrieved.

Export Data
The data retrieved from running a query can be exported to a tab or comma delimited text file by clicking the ‘Export data’ button.

Edit Record
Clicking the ‘Edit record’ button, or double clicking on the record itself, opens the ‘Edit table’ dialog box, (see Figure 9-3)



Figure 9-3: Update record dialog
The ‘ADD’, ‘CHG’ and ‘DEL’ buttons on this dialog box allow for records in the table to be maintained.
The button ‘Back’ retrieves the previous record on this table, and the button ‘Next’ retrieves the next record on the table.

Print Data
Clicking the ‘Print data’ button, presents the ‘Print options’ dialog box, (see Figure 9-4). This allows for all of the retrieved rows of data, or those selected, to be printed.



Figure 9-4: Print options



## Query Considerations
These considerations are as relevant to free queries as they are to SQL statements created in RTQuery.
A database can be case-sensitive.  The AMT Developer Studio Generator produces the database tables, indexes, and items in uppercase.
Also, in the database, any hyphens are translated into underscores in regard to names.
If a new field is added to an existing table, then in all existing records of this table, the new field’s value is initialized with a value NULL. Fields that are part of an index can never contain a value NULL.
Multiple SQL statements cannot be executed in the RTQuery window.


Exercise 7: Use RTQuery in AMT Screens

# AMT LION Debugger

## Generating Debug Objects
From the section 5.3.7 , the ‘Private debug’ checkbox is available in the Generator view of the AMT Developer Studio and the Generator dialog box, (see Figure 10-1). Checking this option generates objects in debug mode.
Generating in debug is indicated in the title of the dialog box once generation  starts.



Figure 10-1: Generate object in Private debug

If the option ‘Generate all children and parents …’ is checked, all objects referenced by the current object are also generated in debug.
In a multiuser environment the AMT Developer Studio Administrator can set the option ‘Generate public in debug’. This creates a debug version with every normal generation that can be used by all developers. The developer can create their own debug version by checking the ‘Private debug’ checkbox when generating an object. When the option ‘Generate public in debug’ is not set, it’s necessary to generate objects in ‘Private debug’ before an object can be debugged.
## Running the Debugger
To run a form in debug mode, the application must be started within the LionDebugger.exe. This tool can be found in the directory: <systemroot>\AmtTools\LionDebugger.


Figure 10-2: Debug object generation process
The LionDebugger runs on the client in a way similar to ‘app.exe’. It needs a connection to the application server and access to the debug versions of the objects.
After starting this tool, a screen is displayed to connect to the appropriate application.
The server and port number of the application service are displayed in the drop-down box ‘Lion Server’.


The debug user must also be selected (this is typically the same as the one used in the AMT Developer Studio). A connection is made by clicking the ‘Connect’ button.

Figure 10-3: AMT Debugger connect to application
The first time a connection is being made with the debugger some settings need to be entered - this can be done by cancelling the initial connection dialog box and selecting the Tools menu, and clicking Options (‘Web Client url’ is only required when debugging using a web interface; the URL points to the AMT Application Center).

Figure 10-4: AMT Debugger connection properties

The application can be started by clicking the icon for start AMT Screens or by selecting ‘Start AMT Screens’ under Run.


Figure 10-5: AMT Debugger Start AMT Screens

The application starts in a separate window. A message appears in the status line as shown in Figure 10-6 indicating that the runtime is started from the debugger.


Figure 10-6: Application started through debugger


Once the user navigates to a form, generated in debug, the form’s code is shown in the debugger as shown in Figure 10-7.


Figure 10-7: LionDebugger

This form is divided into three windows:
## Debug window
In this window the form can be debugged line by line.
Hover the mouse over an item and its value is displayed in a tooltip.
The debugger is an extensive tool.  Most functions are described in this manual, with the next sections describing the debug commands.
### Step in
Clicking this button , or pressing ‘F11’, steps the program execution forwards by one line of code. If the next line is a call to a routine, or an insertable form/report, then the debugger will step into the code of this routine or insertable form/report.
### Step over
Clicking this button , or pressing ‘F10’, advances the program execution to the next line of code. Unlike the “Step In” button, if this next line is a call to a routine, or an insertable form/report, then it will be treated as just another line of code, and the debugger will not step into the code of that routine or insertable form/report. Advancing past this line will cause the code of the routine or insertable form/report to be executed, but it will not be shown in the debug view.
### Continue/Halt
Clicking this button , or pressing ‘F5’, continues the program execution until the next breakpoint, (see Breakpoint section below). If no breakpoint is encountered, then the continuation is until the end of transaction. When the debug session is continuing and still in executable code, the pause   button, or ‘CTRL’ + ‘ALT’ + ‘BREAK’, can be used to halt at the line that is currently executing. This button is greyed out until the continue button is clicked.
### Skip
Clicking this button , or pressing ‘SHIFT’ + ‘F10’, skips the execution of the highlighted line of code, and advances to the next line of code.
### Step out
Clicking this button , or pressing ‘SHIFT’ + ‘F11’, causes the execution to step out of the current routine. The remaining code is still executed, but is not shown in the debug view. If the current routine is ‘display_main’ or ‘process_main’, then the execution is to the end of the transaction.
### Show next statement
In large objects, you may want to scroll through the code to view it, without executing it. To put the focus back on the next line to be executed, the button, or ‘ALT’ + ‘*’, can be used.
### Halt
When the code is processing, this can be interrupted by using the Halt or Break button  or pressing ‘CTRL’ + ‘ALT’ + ‘BREAK’.
### Abort
The Abort button , or key combination ‘SHIFT’ + ‘F5’, will terminate the current debug session. A message, as shown in Figure 10-8, is displayed.

Figure 10-8: Debug session aborted
The current transaction is aborted. Any updates that are not already committed to the database are rolled back.
The debug session can be terminated by closing the debug window or disconnecting from the application.
### Breakpoints
Clicking the Breakpoint button  sets a breakpoint on the highlighted line of code. A breakpoint can be set on lines other than the highlighted line, by clicking on that line of code and then clicking the ‘Breakpoint’ button, or by clicking the blue dot next to the left of the line number, (see Figure 10-9).

Figure 10-9: Setting a breakpoint

Once a breakpoint is set for a line of code, it is indicated by the blue dot changing to a larger red dot, and by also showing the line of code with a red background, (unless it is the highlighted line of code, where it continues to have a blue background, see Figure 10-9).
The ‘begin_routine’ for ‘Display_main’ and ‘Process_main’ are automatically set as breakpoints for debugging forms. To prevent the debugger from halting at these automatic breakpoints, the setting ‘Skip Default Breakpoints’ can be checked in the ‘General settings’ of the ‘Options’.
A breakpoint can be removed by clicking the red bullet to the left of the line number.
All breakpoints can be removed using the ‘breakpoints’ tab in the debug area.
### Conditional breakpoint
There are several ways to add a conditional breakpoint:
- 34.1 Right-click the required item in the debugger code lines and select ‘Add Conditional breakpoint’ from the context menu.


Figure 10-10: Add conditional breakpoint through context menu
- 34.2 Clicking the ‘Conditional BK’ button, presents a dialog box to select the item(s) on which the conditional breakpoint should be set (Figure 10-11).


Figure 10-11: Add conditional breakpoint through variable list
Add conditional breakpoint(s)
Simply select all the fields on which a conditional break should be set. After selection click  and the selected items are shown in the Conditional Breakpoints dialog box, see Figure 10-12.


Figure 10-12: Conditional breakpoint added

Double-clicking an item shows the ‘EditConditionWindow’, see Figure 10-13.
In this window the operator and value can be set to indicate the condition that causes the debugger needs to break.


Figure 10-13: EditConditionalWindow

By clicking  the Operator and value to break are set.
If multiple conditional breakpoints are set, the debugger will break on any one of the conditions being met, and does not wait until all of the conditions are met.
Conditional breakpoints can be enabled and disabled using the buttons  in the toolbar or by right-clicking on the item and select the desired option.
With the conditional breakpoint(s) added clicking the ‘Continue’ button in the debugger will execute the program until one of the conditions is met, at which point the execution of the code will stop at the line where the condition is met.

Change a conditional breakpoint
To change a conditional breakpoint, select from the list of conditional breakpoints and double-click on the item, (see Figure 10-12).
The EditConditionWindow is again displayed, (see Figure 10-13: EditConditionalWindow).

Delete a conditional breakpoints
To delete a conditional breakpoint, select the conditional breakpoint to be deleted from the dialog box and click on or use the ‘DEL’ from the keyboard.
To delete multiple conditional breakpoints, selects all the breakpoints to be deleted, by holding ‘CTRL’ or ‘SHIFT’ and click on the items. After selection use the same delete functionality as for one item.
To remove all the conditional breakpoints at once click the icon.

### Save settings
Clicking either button  or allows the developer to save all the debug settings into a session file for later re-use, (see Figure 10-14).


Figure 10-14: Save debugger settings

### Load settings
Clicking the  button allows the developer to load the session file with the earlier saved debug settings.


## Object Explorer
A treeview contains folders of all the related debug objects. Double-click a related object and the code lines are shown under an extra tab. See Figure 10-15



Figure 10-15: Object explorer

### Synchronize objects
When the generate option ‘Generate public in debug’ is selected for the generation set, all objects are generated for debug automatically. New debug versions of an object are not loaded in the debugger automatically. New objects can be loaded by using the  button or the menu option File Synchronize objects. A list of debug objects is show. See Figure 10-16.


Figure 10-16: List of debug objects to be synchronized

Items that need to be synchronized can be checked. Clicking ‘Start’ synchronizes the AMT LION debugger for the items selected.


## Debug information
As explained in 10.2 the Debug Information window contains several views.
Using one of these buttons or click on the tabs in bottom left corner and different information is presented.


Figure 10-17: Debug information tab sheets

### Messages

All kinds of messages generated by the source code can be viewed here.
In the example Figure 10-18 there is an error from attempting to add the same record again.


Figure 10-18: Messages tab sheet
### Trace

The ‘Trace window’ shows routines that are currently being executed.


Figure 10-19: Trace tab sheet

### Output
All kind of output messages generated by the debugger are viewed here.


Figure 10-20: Output tab sheet
### Call stack
The ‘call stack’ shows the routines that are called. Double clicking on a line highlights the line where the routine was called.


Figure 10-21: Call stack tab sheet

### Watches

A list of items can be added to the ‘watch’ window, to continuously display their current values, see Figure 10-22.


Figure 10-22: Watches tab sheet

#### Adding items to the watch window
There are several ways to add an item in the ‘watch window’:
- 36.1 Right-click the required item in the debugger code lines and select ‘Add Watch’.
- 36.2 Click the  icon and the ‘Watch’ dialog box appears in the bottom window. Now click on the  icon, this opens a dialog as shown in the next figure.

Figure 10-23: Add single watch
- 36.3 Click on  and the ‘Watch’ dialog box is presented in the bottom window. Now click on the second and a similar window appears as described in 10.3.10 Conditional breakpoint (how to select the items is also described in that section).

After selection, the item(s) are shown in the watch window, see Figure 10-22, where the current value is continuously displayed.

#### Changing watch values
Watch item values can be changed while debugging through the code lines.
To change the value of a watch item, right-click the watch item in the watch window and select from the popup menu ‘Edit Value’. The same can be achieved by right-click on the item in the debugger window code lines. The item doesn’t necessarily need to be added in the watch area to change its value.
The ‘Changing watch value’ dialog box is then displayed, (see Figure 10-24). Enter the new value and click the ‘OK’ button.



Figure 10-24: Change ‘watch’ value

The value in the watch window is then changed to the entered value, and the program can now continue executing with this new value.
#### Remove watches
To delete a watch item, select the watch to be deleted from the dialog box and click on or use the ‘DEL’ from the keyboard.
To delete multiple items in the watch list, select all of the watches to be deleted, by holding ‘CTRL’ or ‘SHFT’ and click on the items. After selection use the same delete functionality as for one item.
To remove all watches at once click on .


#### Expanding or collapsing groups
If the item displayed in the watch window is a group/structure, then it can be expanded by clicking on  and collapsed by clicking.



Figure 10-25: Expanding structure
Arrays can also be expanded in the watch window just like structures. When checking the ‘Show Expanded Sign’ the user can see which (complex) watch items are expanded. In the watch window the array definition of an array item will be displayed in the edit column instead of in the name column.

#### (De)select watches
With every step through the code lines, the debugger needs to check the watch list if values change. When there is a big watch list or there are collapsed items, this can be a time-consuming process and can impact performance of the debugger. By clicking the  icon, all watches are deselected and are ignored by the debugger.
To select an item again just mark the item as selected.


### Debugger logging
Some basic information is logged while using the debugger, this only concerns the starting and closing of the debugger by a user. Logging of the debugger is spread into 3 logfiles.


#### AMT LION Debugger Host
There is a ‘LionDebuggerHost<id>.log’ where <id> is an internal id per debugger session, example: ‘LionDebuggerHost7724f915-06bb-44ab-9be2-457acf54ecc7.Log’
This file is placed in the <Logging path> of the application. Contents of the files are also viewable in the Control Center at ‘Processed>Logging>Logfiles’ and then select the logfile.

Figure 10-26: LionDebuggerHost.log example

#### AMT LION Debugger
There is a ‘LionDebugger.log’ per day in the folder ‘AmtTools\LionDebugger’, this folder is within the <AMT-rootfolder>. 
Contents of this file cannot be viewed in the CC.

Figure 10-27: LionDebugger.log example
#### Bug reports
Whenever there’s a severe error or crash, a bug report is generated. These can be found in the <Logging path> of the application.


Figure 10-28: LionDebugger bug report



Exercise 8: Use LionDebugger

# Forms Advanced Possibilities
## Changing visual object properties at runtime
Visual objects have many properties that can be maintained with the Object Inspector in the ‘Screen Layout’. Some of these properties can also be altered in the program code. This enables the developer to influence the properties of visual objects at runtime, or based on an action, not just at design time.
Some properties only apply to certain types of visual objects. To view a list of the properties available for an item, type the name of the item followed by a period. A code completion list appears with the properties that are available, (see Figure 11-1).


Figure 11-1: Visual object properties
The property can be selected from the list, by double-clicking on the property, or selecting the property and pressing the ‘Enter’ key. Once a property is selected, the code completion list disappears and the code line is automatically completed with the chosen property, ready for any assignments.
The following section gives details on the most commonly used properties.
### Caption
The text of most visual objects (e.g. label) a value can be assigned to this property. When the visual object is a group (e.g. button group), then each element of the group is referenced within square brackets.
Example syntax:
label_name.caption := 'New Caption Text Here'
button_action.caption[1] := 'OK'
button_action.caption[2] := 'Cancel'

### Enabled
The ‘enabled’ property is used to enable or disable visual controls. If the visual control is a group, then it is possible to disable the children of the group in one action.
Example syntax:
button_action.enabled[] := false

Alternatively, elements of the group can also be enabled, by referencing the element within square brackets.
Example syntax:
button_action.enabled[1] := true
button_action.enabled[2] := false

### Font properties
There are several properties for changing the font. These are ‘fontbold’, ‘fontcolor’, ‘fontitalic’, ‘fontname’, ‘fontsize’ and ‘fontunderline’.
AMT Developer Studio provides in the global definitions a number of colors, (see section 12.1.8 Colors), that allow for the colors to be referenced by the global definition name.
Example syntax:
cust_no.fontcolor := clRed

Alternatively, hex values can also be assigned:
Example syntax:
cust_no.fontcolor := $0000FF


### Helptext
The property ‘helptext’ is used to set help text on a visual object. The text is displayed when the mouse pointer is moved over a visual object.
Example syntax:
button_ok.helptext := 'Push this button to confirm'

The time the helptext is shown can be set in the Control Center (the default is 3.5 seconds).
### Readonly

The property ‘readonly’ is used to prohibit an edit field from being altered.
Example syntax:
name.readonly := true

### Setfocus

The ‘setfocus’ is more a command than a property, and as such is colored blue by default, rather than the other properties that are colored black. The ‘setfocus’ programmatically positions the cursor on a visual object. If more than one ‘setfocus’ is encountered within the program code of an object at runtime, then the last one that is encountered is executed.
Example syntax:
if cust_no = 0 then cust_no.setfocus

### Visible
The ‘visible’ property is used to make a visual object visible or invisible at runtime.
Example syntax:
if user_auth
button_action.visible := true
else
button_action.visible := false
endif

## Insertable forms
Insertable forms are used to add the same visual objects into multiple forms. For example, an insertable form may provide the ‘header’ and/or ‘footer’ for a form. To the end user, the interface appears simply as one form, not two separate objects.
### Creating an insertable form
Insertable forms are created in a similar way to Application forms, (see section Error! Reference source not found. Error! Reference source not found.).  From the repository right-click on the folder ‘Insertable Forms’, within the ‘Forms’ folder, and select ‘Insert Insertable Form’, and complete the popup dialog box.
Insertable forms have a screen layout canvas, the same as application forms. This allows for visual objects that are required on multiple forms to be created and maintained in just one place, (see Figure 11-2).



Figure 11-2: Adding screen layout for Insertable Form
When adding the visual objects in an insertable form, it’s important to choose unique item names that are not used inside the layout of existing forms that will ultimately call this insertable form (otherwise validation errors will occur).

Definitions and code can be specified in the insertable form, (see Figure 11-3).


Figure 11-3: Insertable Form code
There are no routines within an insertable form. This is due to the fact that when this object is generated, it is physically inserted into the calling form and becomes part of the calling form.  Due to the insertion, an Insertable Form might not appear to validate, but the code will generate if syntactically correct.
### Using an insertable form
Insertable forms can be added to a form in one of two ways. One way is to click on the section ‘Included forms’, from the navigation tree within the calling form, and select ‘Add new include object’.
This presents the ‘New included form’ dialog box. The new Insertable Form can then be selected from the drop down list, (see Figure 11-4).

Figure 11-4: Include form dialog
Once selected the Insertable Form is added to the navigation tree on the left, under the option ‘Included forms’, and a call to the insertable form is also added in the ‘display_main’ section of the code editor (see Figure 11-5). Be aware that if the Insertable Form contains code that needs to be executed in ‘process_main’, then the Insertable Form also needs to be added to the ‘process_main’ section.


Figure 11-5: Insertable Form added

The alternative way to add the Insertable Form, if the name is known, is to just call the Insertable Form from within the code editor, then validate and save. This then adds the Insertable Form to the navigation tree on the left and into the screen layout.
The visual objects, of an Insertable Form, are visible within the calling form’s screen layout canvas, but can only be maintained from the Insertable Form. However, the visual objects of the Insertable Form can be referenced in the code of the calling form, and its properties changed from there.

When setting the tab orders, (see section 3.4.20 Changing the tab order of Visual Objects) the ‘Edit taborder’ dialog box now shows the name of the Insertable Form, so that its tab order can be amended as required.


Figure 11-6: Tab order with Insertable Form

Exercise 9: Create Insertable Form.





# Advanced options and code
## Global Options
Every application contains a set of global options that are valid throughout the entire application. To access these global options right-click on the application folder, and from the popup select ‘Options’.
### Options

Figure 12-1: Application global options
The global options are an object in their own right, so before any global options can be changed, the global options object needs to be ‘locked’. To lock the global options object, click the ‘Edit Object’ button , from the main developer toolbar, (see Figure 12-1).
The ‘Name’ and ‘Description’ of the application can be maintained from here.


Decimal Sign
This allows for the default decimal sign to be either a ‘Dot’ or a ‘Comma’.

Force decimal key
If this option is set to ‘Yes’, values entered in items that are specified as decimals will be rejected if they don't contain the decimal character. Setting this option to ‘Show no decimal key’, results in decimal values not being shown in items that are specified as decimals.

Show leading zeros
This option sets the number of leading zeros to be shown in the application when displaying numerics. If set to ‘None’, no leading zeros are displayed for numeric values. If set to ‘One’, a zero will only be shown if the value is zero, and if set to ‘All’, and the value is less than the value length supports, the value is completed with leading zeros.

Numeric Sign Encoding
This setting defines how overpunching is applied (i.e. the last digit of the numeric value is changed based on the sign of the value).

Automatically LOCK record
If this option is set, then developers do not have to worry about locking records while reading them from the database. Every table from which records are read, that are going to be updated in the transaction, are automatically read in locked mode. In that same transaction, if records are read from other tables but there is no update in those tables in this transaction, then they are not read in locked mode.
In the options of forms and reports is also this option to lock records. Therefore, the ‘default’ setting in forms/reports inherits the setting here in the application options.




Tabforms setting
The settings here determine if multiple application forms can be opened in separate tabsheets, and what occurs with the session data (i.e. the retained variables and session data).
The option ‘Single Tabform with Shared Session Data’ only allows for one application tabsheet at runtime.
The option ‘Multiple Tabforms with Shared Session Data’ allows for multiple application tabsheets to be opened at the same time, with each tabsheet sharing its session data with the other tabsheets.
The option ‘Multiple Tabforms with Private Session Data’, allows for multiple application tabsheets to be opened at the same time, but each tabsheet has its own session data, which is not shared with the other tabsheets.

Size of SI-PARAM.
SI-PARAM is a system item that is used to pass parameters to and from reports, or external Windows dynamic link libraries, (dlls). By default, this item is 4000 bytes, but if needed its size may be changed.

Application Origin
Indicates the Mainframe OS type from which this application is converted. When set to ‘Unix’, numerics containing only spaces get converted to 0 on assignments. The possible application origins are defined within the AMT Developer Studio license.

File record ending
Indicates how extract file records are terminated. The most common setting is ‘CR/LF’. When communicating with other (mainframe) systems, this setting can be changed to use ‘CR’ or ‘LF’ as a record terminator.

Initial value of variables
To mimic the behavior on the mainframe, AMT can be set to act in the way variables are initialized on the mainframe. This is generally only necessary when there is specific code written against the initial value of the variables.


Printing
The option ‘Write <LF> before new print layout’ will write a line feed before a new print layout. Before contemplating the use of this option, it is recommended to test this thoroughly to find out the exact consequences in your environment.

Unicode
When the option ‘Define Unicode for all extract files’ is set, the files created by AMT will be encoded in ‘UTF-16’ (two 8-bit bytes will be used for every character). This increases the size of the extract files and should only be necessary when special characters are used in files that are exchanged with external applications.

ReadFile
If this option is set, the read actions with Readfile() … EndRead() will open a file in shared mode. If the option is not set, the file is locked until the file is released by the program.

Listbox
Checked: The listbox file is created only in the folder with the name of the creating station. This file can only be read by the user on this specific station.
Unchecked: When creating listbox files with the ‘Fillbox’ command the file is created in the general Listboxes folder as set in the AMT Control Center’s settings and in a folder with the Station name of the creating station. The listbox file in the general directory is for all users to read.

Inspect
Checked: The AMT LION behavior of INSPECT COUNTING is used (i.e. the count variable is initialized to zero before the count and the count result will therefore overwrite any value previously set in the count variable).
Unchecked: The original COBOL tallying behavior of INSPECT COUNTING is used (i.e. the count variable is NOT initialized to zero before the count and the count result is added to the current value of the count variable).



Embedded fonts in PDF reports
Normally, the font information is included in PDF files to show the PDF in the correct font without the need to download the selected font.

Dictionary
If the radiobutton ‘Table fields don’t need to be linked to a dictionary’ is checked, then the dictionary is not enforced, and tables may contain non-dictionary items, (see section 12.2 Dictionary).
### Database options
Database options are generally maintained by a Database Administrator.
Figure 12-2: Application global options

Primary key
If the option ‘Create primary key on Lionrecno’ is checked, the primary key is set on the Lionrecno field by default. If an index uses the option ‘Set as Primary Key’, then this setting takes precedence over the application setting.

SI-DBSTATUS
If the option ‘Set SI-DBSTATUS on deadlocks/locks etc.’ is checked, then SI-DBSTATUS by default, is set when specific table or cursor queries cannot be executed. Application options setting can be overruled in the options of the objects themselves. The values for ‘si-dbstatus’ are as follows:

Table 12-1: SI-DBSTATUS values

Fill factor
If the option ‘Use default fill factor for indexes defined in SQL’ is checked, then the default fill factor is inherited from the SQL database. If this option is unchecked the default fill factor is then specified in AMT Developer Studio. This value should be calculated on the number of records being created/changed in the concerned table. Details in determining a suitable fill factor are found in the documentation of the SQL database. The applications default fill factor can also be overwritten in Index objects (setting the value incorrectly can have a big impact on performance).

Unicode
If the option ’Define Unicode alpha fields for all tables’ is checked, all new created database alphanumeric fields are encoded in ‘UTF-16’ by default.

Lionrecno
If the number of records exceeds 999,999,999, the Lionrecno field needs to be set to numeric 18 by checking the option ‘Define LIONRECNO as Numeric 18 (instead of 9)’.

No index
The option ’No index on Lionrecno’ is only valid when an Oracle runtime database is used.


Abort
To mimic mainframe behavior, the settings ‘Abort transaction when deleting a non-existing record’ and ‘Abort transaction when updating a non-existing record’, can be set.

Add timestamp fields
As explained in section 0, the fields ‘LIONCREATEDDATE’, ‘LIONCREATEDTIME’, ‘LIONMODIFIEDDATE’ and ‘LIONMODIFIEDTIME’ can be added to a table. The default behavior is configured with this setting.
By using different versions of the application options, this setting can be different in the available ‘generation sets’ (e.g. the default behavior in a Development ‘generation set’ can be set to ‘include timestamp fields’ but in the Production ‘generation set’, the version of application options with the checkbox ‘unchecked’ can be active).
After changing this setting, all tables that are set to the default behavior, will need to be generated and the database must be reorganized.

Overwrite Collation Sequence
Changing the Overwrite Collation Sequence setting can greatly impact an AMT environment, therefore it is strongly advised to consult with Asysco before changing this setting.

With the overwrite collation sequence it is possible to set the application database to a case-insensitive collation while using a case-sensitive collation for the data itself. This allows for queries with mixed case to be executed correctly, for example: "SELect * fRoM taBLe1".

Per database kind a (case-sensitive) collation sequence can be set which will then be used for the data (alpha/string fields) of new table fields. The developer is responsible for specifying the correct collation value. The reorganization program uses this collation when new tables/fields are added. It is strongly advised to only use the overwrite collation sequence for new applications/databases.

Changing the collation for existing tables/fields is NOT supported.
The reorganization program shows warnings when it finds tables/fields with a different collation sequence but will not execute the change.
Migrating existing data must be done manually by creating a new database with the correct (case-insensitive) collation sequence, running the reorganization program to create tables/fields with the overwrite collection sequence, copying existing data to the new database, testing and finally removing the old database.

### Dates
Clicking the ‘Dates’ option on the navigation tree opens the details panel seen in Figure 12-3.


Figure 12-3: Date options

Week number calculation
If ‘Use ISO 8601 standard’ is checked, then the ISO-8601 standard is used to calculate the week number. This calculates week one of a year as being the week where the 1st day of the year falls between Monday and Thursday inclusive.
When ‘Use ISO 8601 standard’ is unchecked, then the USA method of calculating the year is used where week one of a year is the first complete week in the new year, where the week begins on a Sunday.

Shifting time frame
When the century of a date is not specified, the application can calculate which century to use from the ‘Shifting time frame’ specified.
So, for example if the ‘Shifting time frame’ was set at '54', then this figure would be added to the current year (e.g. '21'), to give a splitting point of '75'. Any 2-digit year less than this splitting point would be considered to be in this century (i.e. 20xx), and any 2-digit year greater than or equal to this splitting point would be in the previous century (i.e. '19xx').
Shifting time frame is the default behavior for new applications, to use a different method you can set ‘Century start year’ or choose a different SI-century behavior than the default ‘Don’t use as input only set’.

Date validation
Establishes the specification for the lowest and highest year value for a ‘Valid date range’. If a year value (ccyy) is not within this range, then the dateresult function (see section 12.3.3 Dateresult), sets ‘resok’ to false and returns the date as today.
If ‘Allow 1 digit as day/month/year for formats with a “-” inside’ is checked, then it is possible to indicate the month/day/year (or day/month/year depending on date format) with a single digit in formats with a ‘-’ inside, (e.g. 1-1-99).

Day and month naming
Allow the setting of how AMT handles the regional day and month naming by the server. If the option ‘long day names’, ‘long month names’ or ‘short month names’, under the section ‘Use regional of the server for’ are checked, then AMT LION will use the Windows date descriptions on the machine where the Application/Batch service is running for the selected option, instead of the values that are specified in the ‘Day names’, or the ‘Month long and short names’.

#### MaskDefinitions
On a form, a special kind of edit box can be used. This MaskEditbox uses a mask to validate the user input when it is entered. The masks that can be used are defined in the Application MaskDefinitions (e.g. ‘___-___-____’).

### Documentation
This section allows for documentation to be added about the global options.
### Languages
AMT Developer Studio is a multi-language development environment. All layouts of forms and reports can be built in more than one language, with one ‘Implementation’ section.
At runtime, the end-user is presented with the screen layout of the language that is defined by the system variable SI-LANGUAGE.
In ‘Languages’ the developer maintains the list of valid languages. To add an extra language right-click in the languages box, and select from the context menu ‘Insert’, see Figure 12-4).


Figure 12-4: Add a language
A dialog box appears for the new language name to be entered, (see Figure 12-5).


Figure 12-5: Add language dialog
Click the ‘OK’ button, the entered language is added to the list.
Languages can then be enabled/disabled in AMT Developer Studio by checking, or unchecking, the appropriate language checkbox.
Once the application options are checked in, a layout for each language is displayed, (see Figure 12-6) when entering an object with a layout.
After adding an extra language, all existing objects that were originally designed for one language will still have the original layout for the default language.
In AMT Developer Studio, when opening the layout builder for another language(s), an information dialog box appears asking to ‘Copy from Default’, (see Figure 12-6).


Figure 12-6: Add layout items in other language
When ‘Ok’ is clicked the original default, layout is copied to the new language’s layout.
### Checking in global options and generating
The Global Options of an application are themselves an object in the AMT Developer Studio.
After the initial setup, most changes are to Global Definitions (section 12.1.7 Global definitions), which includes, Variables, Constants, Table Queries and Dictionaries (Section 12.2 Dictionary). These areas of the Global Options first need to be checked in before they can be used in other areas of the AMT Developer Studio (See section 7.2 Checking in Objects).
By generating the Global Options, Definitions or Dictionaries after check-in, AMT Developer Studio automatically recognizes the objects that need to be regenerated due to any changes made.
### Global definitions
Selecting ‘Global Definitions’ from the navigation tree shows the definition blocks that are defined. A definition block can contain ‘Variables’, ‘Constants’, ‘Retained session data’ or ‘Redefines’. By default, there are two established sectioned in Global Definitions, ‘Colors’ and ‘Variables’. Each section can be checked in/out separately. These sections can be added and removed freely.
Global Definitions can be used in all objects, (e.g. Forms, Reports, Global Routines etc).


Figure 12-7: Global definition types
The definition of Variables and Constants at the global level conveys two major advantages. The first is that a developer only need declare a variable once, instead of in each object. The second advantage is that it also provides the scope to pass data in a transaction between a Form or Report, and a global routine.
### Colors
Double-clicking ‘Colors’, under Global Definitions, opens the ‘Colors’ window, see Figure 12-8. The most commonly used colors are predefined when AMT is installed.
Developers may add/change/delete the colors needed, in the same way they can change Constants/Variables.


Figure 12-8: Color definitions

### Constant
The ‘Constant’ data type is meant for variables that contain a fixed value. Although this value can be changed in code, it’s recommended not to change the value and to use the ‘Standard’ block type instead when that’s required.
‘Constants’ are defined in the same way as all the other global variables, see Figure 12-9.


Figure 12-9: Global Constant
### Redefines
These variables are used to declare a common-storage area. In the report or global performable routine, you can now declare variables which can be redefined from these common-storage variables (where normal globally defined variables cannot be redefined in the code).
Only single alpha variables are allowed in the Redefines section.
### Sessiondata
Variables defined here are retained throughout the session and are not initialized at the start of a transaction in a form.
Variables are defined here in the same way as ordinary variables, but can be used to transfer values from one screen transaction to another. Each end-user has their own set of variables that are dedicated to a session.
These variables can also be used in reports, but their importance of retaining values is meaningless, as they are essentially just ordinary variables when referenced in a report.

Session data is stored in the database after each transaction.
It’s possible to save the session data when the session is closed by the user, and then restore it when the user logs on again. The setting ‘Clean sessiondata on userconnect’ is controlled in the AMT Control Center.
### Variables

Double-clicking on a variable opens the Object Inspector window, (see Figure 12-10).


Figure 12-10: Global Variable

All types of global variables can be defined here including Colors, Constants, etc.
To add a global variable, the block must first be in edit mode, then the Variable(s) can be added in the same way as already shown when building tables, (i.e. by using the Object Inspector and/or the ‘bulk mode’), see section 0
Defining fields in a table.
At the start of a transaction in a Form, or at the start of a Report, all Global Variables are initialized, (see section 6.3 Form Flow).
All applications already are created with one Variable pre-defined, ‘dateresult’, of the type ‘date’, (see Figure 12-10). This is described in more detail in section 12.3.3 Dateresult.


### Adding a new block

A new Global Definition block can be added in the same way that Forms can be added.


Figure 12-11: Adding new Global definition block

A dialog box is displayed. The ‘Name’ and ‘Description’ fields are required.


Figure 12-12: Add new Global definition block dialog


After clicking “OK”, the option screen of the Global Definition block is shown. See Figure 12-13.


Figure 12-13: Global definition options

#### Options
‘Standard’ indicates that this Global Definition block can contain all kind of definitions. For example, Variables, Table Queries, Colors, etc.
Selecting ‘Constants’ means this can contain Variables that have a value that is not changed in the code. Constants are initialized to their constant value at the start of a transaction.
‘Retain’ are variables that are initialized at the start of the session only. Values can be set in the code of Forms, Reports and Global Routines. Values are maintained through the duration of the session.
‘Redefines’ are a special kind of variables. In this block, variables can be defined that share the same piece of memory.


### Global definitions

In this section, the actual Definition is added in the same way Definitions are added in Forms or Database tables. See Figure 12-14.


Figure 12-14: Adding a field to a Global definition

#### Documentation
This section allows for documentation to be added about the global options.

#### Relations
This section shows a list of objects where this definition block is used.


### Global query variables

Table Query, Cursor Query, and Free Query variables can be defined in the variable definition block in the ‘Global definitions’ as described in the previous section.
However, it’s good practice to put all query variables in a separate definition block to improve maintainability.
A table query variable is an ordinary variable that can be defined in a ‘standard’ block.
This is done by inserting an item and specifying the type as a ‘TableQuery’, ‘CursorQuery’ or ‘Query’, and then in the case of a table query or cursor query entering the table name in the ‘Initial value’, (see Figure 12-15)



Figure 12-15: Global query variable



## Dictionary
The ‘Dictionary’ section allows for fields to be defined that will serve as a ‘parent’ to ‘child’ fields defined in Tables, Routines, Forms and Reports. These ‘child’ fields inherit the type and length from the parent item.
Clicking the ‘Dictionary’ node the current dictionary items are displayed in the right-hand window as shown in Figure 12-16. Fields can be added, changed (Dictionary items can only be deleted using the revision screen). This is the same for all objects.
Every dictionary item is a separate object that can be locked and checked-in.


Figure 12-16: Dictionary

### Inserting a dictionary item

Right-click on ‘Global Dictionary’ in the left-hand tree view, or right-click in the right-hand list view, (see Figure 12-17).


Figure 12-17: Adding Global Dictionary

The ‘Name’ and ‘Description’ are required.


Figure 12-18: Adding Dictionary dialog


After clicking ‘OK’, the option screen is shown.


Figure 12-19: Dictionary definition
Here, the ‘Type’, ‘Length’ and ‘Decimals’ must be defined.

### Using dictionary items
Only dictionary items that are declared in the ‘Dictionary’ section and checked in, can be used.
To declare a variable to a dictionary item in the definitions of an object, do not declare the type and length, simply just add the text ‘dct’ and the name of the dictionary item.
Example syntax:
var
vn-cust-no : dct dct_cust_no


To declare a visual object, or the field of a table, to a dictionary item, use the Object Inspector and change the property ‘Dictionary’ to the name of the item, (see Figure 12-20).


Figure 12-20: Dictionary item used

Once the relationship with a dictionary item is entered the ‘Type’, ‘Length’ and ‘Decimals’ properties are no longer maintainable, and are greyed out (disabled).

### Global Dictionary list
A complete list of available dictionary items can be inquired from the View menu (View > Global Dictionary List). This list can be sorted to easily find a dictionary item.

## Dates
### Today
The system item ‘today’ provides the current date and time in many formats.
Figure 12-21, show the AMT Developer Studio providing auto completion of the today format.


Figure 12-21: Date formats



### Definition type date
The definition type of ‘date’ allows for the assigning of dates, and the automatic conversion of a date into many formats.
When a date is assigned to the date variable, the format of the date being assigned must be added to the date variable. The date is then automatically calculated and available in all the other formats. If an invalid date is specified then today’s date is returned in all the formats, and the system item ‘resok’ is set to false.
Example syntax:
var
vd-date : date

routine display_main
begin_routine
vd-date.ddmmccyy := '14092017'
sme ('Date is' + vd-date.dd-mmm-ccyy)
end_routine


### Dateresult
Upon creation of a new application a Variable named ‘dateresult’ is declared with a type of ‘date’ within Global Definitions.
This variable is used in the same way as the previous section’s locally declared date variable, only that as it exists within global definitions it is available throughout the application.
Example syntax:
dateresult.ccyymmdd := tq_delivery.delivery_date
vn-invoice-daynum   := dateresult.daynum + 31

Initially, dateresult contains the current date.
When an invalid date is assigned to ‘dateresult’, the value is also set to the current date and the global system variable ‘resok’ is set to false. It’s good practice to check ‘resok’ after a date assignment.
## Advanced Code Commands

As confirmed in the first section of code commands, there are a multitude of code commands available in AMT LION. The following are commands that are commonly used and may prove useful in completing the upcoming exercises.
### With … Endwith
The command ‘with … endwith’ is a block building construct that reduces unnecessary typing. Any place in the program code, where repetitively the same literals have to be used before a period, it may be replaced by the ‘with … endwith’ command.


Figure 12-22: With … Endwith
Example syntax:
tq_customer.compname := va-compname
tq_customer.street   := va-street
tq_customer.city     := va-city
tq_customer.postcode := va-postcode
tq_customer.country  := va-country

can be just as easily typed as …
with tq_customer
.compname := va-compname
.street   := va-street
.city     := va-city
.postcode := va-postcode
.country  := va-country
endwith

### Loop While
The ‘loop while’ statement evaluates a condition before starting a new iteration of the loop. The loop will only process the contained code while the condition is met, otherwise it breaks. Alternatively, a break condition within the loop can also force the loop to stop.

Figure 12-23: Loop While

Example syntax:
loop while vn-occurrence <= 15
display_repeatingfields ()
endloop

### Loop For
The ‘loop for’ is a command that performs the exact number of iterations of a loop, unless some form of breaking occurs within the loop itself. A variable and the range of the loop must be specified.


Figure 12-24: Loop For
The ‘step’ option is the value that is added each time to the variable. If this is not specified, then the default value is +1. There is no need to code an increment of the variable specified in the loop itself as this is done automatically.
Example syntax:
vn-maxoccurrence := 15
loop for vn-occurrence := 1 to vn-maxoccurrence
display_repeatingfields ()
endloop

#### Labels and Goto
The command ‘Goto’ can be used to jump to a label, where the execution of the code continues from the label. A label is prefixed with a colon (e.g. :next-record).



Figure 12-25: Goto
Example syntax:
tq_customer.index ()
loop tq_customer
vn-tot-customers += 1
if tq_customer.mailing <> 'Y'
Goto (next-record)
endif
send-mail ()
:next-record
endloop

The example syntax above is shown as a ‘Goto’ within a loop. It is also allowed to ‘Goto’ a label outside of a loop, however if this is done in a table query loop, it does not close the table query cleanly, and may cause recursion errors. Therefore, if used, it must be used with caution.
Jumping backwards is allowed, but again take good care that it does not result in an endless loop or make the code difficult to debug or maintain.
A combination of a ‘Goto’ and a label can only be used within the same routine. It is not possible to jump outside of a routine.

### Continue
The code example in previous section can be changed by using the ‘Continue’ command. When the ‘Continue’ command is executed, the code jumps to the next iteration of the loop.
Example syntax:
tq_customer.index ()
loop tq_customer
vn-tot-customers += 1
if tq_customer.mailing <> 'Y'
continue
endif
send-mail ()
endloop

### In
The ‘in’ command can be used to test if a value is within an item, variable or set.
A range of values can be defined with two periods. In the example syntax below, ‘9..12’ specifies the range 9 to 12, (i.e. 9, 10, 11, 12).
Example syntax:
if vn-value in [1, 4, 9..12, 19]
perform-in-routine ()
else
sme ('Error', 'Not in Set')
endif

The ‘in’ command can also be used to setup a boolean value.
Example syntax:
vb-found := (vn-value in [1, 4, 9..12, 19])

### All
The command ‘all’ can be used to test if a variable is filled totally with a specified character.
Example syntax:
if all (va-10, '*')
sme ('va-10 is all-stars’)
endif

if all (vn-6, '9')
sme ('vn-6 is all nines')
endif

### Copy
The command ‘copy’ returns a sub string from an item. The example copies 20 characters starting at the 21st character.



Figure 12-26: Copy
Example syntax:
va-lastname := copy (va-fullname, 21, 20)


### Replace
The command ‘replace’ changes the value, or a part of the value, of a target field.



Figure 12-27: Replace
Example syntax
replace (va-fullname, 21, va-lastname)

### Unstring
The command ‘unstring’ returns the left part of a string until a specified character delimiter is reached. Each unstring operation automatically updates the ‘position’ variable to the next character after the detected delimiter.



Figure 12-28: Unstring
‘Multiple occurrences’ is a boolean value that determines the value to return where multiple delimiters in the ‘source’ are found directly next to one another. If the value is false, which is the default value, then consecutive occurrences of the delimiter are treated as one single occurrence.
The position variable is updated to the point of the first encountered non-delimiter character. If the value is set to true, the position variable is updated to the first position after the first encountered occurrence of the delimiter.

In this case the position is set to a delimiter character. Therefore, the next unstring will return a value of spaces.
Example syntax:
vc-days     := 'Mon/Tue/Wed/Thu/Fri/Sat/Sun'
vn-position := 1
va-day1     := unstring (vc-days, vn-position, '/')
//
// now va-day1 is 'Mon' and vn-position is 5
//
va-day2     := unstring (vc-days, vn-position, '/')
//
// now va-day2 is 'Tue' and vn-position is 9
//

More than one delimiter can be used.
Example syntax:
vc-letters := 'ABC+DEF-GHI'
va-part := unstring (vc-letters, vn-pos, '+', '-')

### IndexOf
Returns an Integer specifying the position of the first character of the first occurrence of <Search value> within <Source>. Optional a start position other than the beginning of <Source> can be specified.


Figure 12-29: IndexOf

When <Search value> is not found zero is returned. Zero is also returned when <Start position> is greater than the length of <Source>, less or equal to zero or when <Search value> is an empty string/alpha.

### RightCopy
Returns the last <N-chars> of <Value>. When <N-chars> is greater than the length of <Value> only the available characters are returned. The returned value is of the type RealString.


Figure 12-30:RightCopy
<Value> must be of type Alpha, String, RealString, Numeric or Financial. 

<N-chars> must be of type numeric, integer or a literal value. A literal value less or equal than zero is rejected during generation. A runtime value less or equal than zero returns an empty string.

<Ignore trailing spaces> must be of type Boolean and defaults to False. When placing the value 'abcd' in an Alpha 5 and then do a RightCopy on the last 3 characters the RealString 'cd ' are returned. When copying with <Ignore trailing spaces> set to true 'bcd' is returned.

When <Value> is of type Numeric or Financial, data is always copied from the end with no trailing spaces, unless full zero suppress or a format allowing trailing spaces has been set. In that case the <Ignore trailing spaces> can be used. When a format is defined for Numeric or Financial data, the format is used for the copy, otherwise normal formatting rules for copying to an alpha field are used.

### Inspect

This command allows you to examine the contents of a variable. There are three sub options:
- 42.1 Converting: Converts characters in source-string to characters in target-string
- 42.2 Counting: Counts occurrences of characters
- 42.3 Replacing: Replaces the source-string by the target-string
All three sub options can be used in one INSPECT statement.


Converting


Figure 12-31: Inspect Converting

Example syntax:
va-inspect := '**AB**CD**EF'
inspect (va-inspect)
    converting ('AC*', 'zla') // va-inspect will be
// 'aazBaalDaaEF'
endinspect


Counting
Example syntax:
va-inspect := '**AB**CD**EF'
inspect (va-inspect)
    counting (result, all, '*') // result will be 6
endinspect

LEADING and TRAILING can be used in the same context.
Example syntax:
va-inspect := '**AB**CD**EF'
inspect (va-inspect)
counting (result, all, ‘*’)		     // Result = 6
counting (result, all, [‘*’, ‘C’, ‘D’])    // Result = 8
counting (result, all, ‘*’, before, ‘C’)   // Result = 4
counting (result, characters, before, ‘C’) // Result = 6
endinspect


Figure 12-32: Inspect Counting

Replacing


Figure 12-33: Inspect Replacing

LEADING and TRAILING can be used in the same context.
Example syntax
sa-10 := ‘AB**CD**EF’
inspect (sa-10)
replacing (all, ‘*’, ‘-’, after ‘D’)    // sa-10 = ‘AB**CD--EF’
replacing (all, [‘A’, ‘E’], [‘Q’, ‘P’]) // sa-10 = ‘QB**CD--PF’
endinspect

### Random
This function can be used as a random number generator.
- 42.4 No decimals are generated in the result.
- 42.5 When passing 0 or smaller, then a 0 is returned.

Figure 12-34: Random

Example syntax:
numvar1 := random(100)
// This returns a number greater or equal to 0 and less
// than  100

numvar2 := random(1000)
// This returns a number greater or equal to 0 and less
// than 1000

## Repeating visual objects
Often applications require forms with repeating visual objects in a column, and/or row layout. In AMT Developer Studio these visual objects are defined with the property ‘OccursData’, which automatically creates an array of the objects. Each object is then addressed with an index in the code.
To create a visual object that repeats, click the option button next to the property ‘OccursData’, (see Figure 12-35).


Figure 12-35: Repeating visual objects

In Figure 12-37 the ‘Occurs times’ vertically is added as ‘6’, and the ‘Other offset’ is set to ‘38’.


Figure 12-37: Repeating Visual objects added

The repeating items are then referenced programmatically by their element within square brackets.
Example syntax:
dsp_cust_no[1] := tq_customer.cust_no


For an object that repeats both vertically and horizontally the object is referenced by two elements. The first element is the horizontal occurrence, the second element the vertical.
Example syntax:
price[2,10] := tq_price.price_1



Exercise 10: Create Form with repeatable options.
# Routines
## Global Routines
Global routines can be called by any other object. There are three types of global routines, insertable, performable, and dll. These kind of routines consist of program code only -- no layout. A fourth type is the ‘Includable Global Variables’. This type consists of variable definitions that can be called in the definition section of the code.

### Insertable global routine
At generation time an insertable routine does not become an object in its own right. Its code is generated within the calling form/report at the point where it is called. If the insertable global routine is called several times by the same form/report, then the code will be inserted several times in the code/report. The result is therefore only the form ‘dll’, or report ‘exe’ file, ends up containing the logic of the insertable global routine.
Due to this, an insertable global routine may not to be syntactically error free, because it is not validated until generation. At that point the form/report calling the insertable global routine must be syntactically error free, after the insertion of the code from the insertable global routine.
The insertable global routine can have constants and variables declared, but these Constants and Variables are added at generation time to the object in which they are inserted, so duplicates in names might occur, which will cause generation errors.


To create a new insertable global routine, right-click on the system folder ‘Insertable Global Routines’, and navigate in the popup menu to the ‘Insert Glb Routine', (see Figure 13-1).



Figure 13-1: Insert Global routine

The dialog box ‘New Global Insertable Routine” is presented, (see Figure 13-2), for the entry of the insertable global routine name and description.


Figure 13-2: Insert Global routine dialog
After entering the name and description, the ‘Options’ detail pane of the insertable global routine is presented, (see Figure 13-3).


Figure 13-3: Global routine options

The Type drop-down, (see Figure 13-3), allows for the global routine type to be changed.
‘Database’ options are the same as those seen in earlier objects, (see section 12.1.1 Options).
The ‘Printing’ options are described in the reports section 16.2.1 Printing options.

Clicking Implementation (left navigation tree) displays the code editor with a definitions section.
Because the code of an insertable routine is added directly into the calling object, routines cannot be specified in insertable global routines.
Code must be entered directly after the ‘end_definitions’ section as is done when creating an insertable form, (see Figure 13-4).



Figure 13-4: Global ‘Insertable’ routine code

### Performed global routine
A Performed global routine is generated as a separate runtime object. This type of routine can be found in the ‘..\Binaries\Common\Libraries’ directory.
When a performable routine is called by a form or report, a memory area is instantiated to pass values of variables. This memory area is unique for each transaction.
A performable global routine must be syntactically error free.
Like a form, all code within a performable global routine must be contained within the routine and must contain at least one routine called ‘main’, (see Figure 13-5).
Constants and variables that are declared within a performable global routine, are only available to the routine itself, (i.e. they are not accessible within the object that is calling this routine). Constants or variables of the same name can exist in the object that is calling this routine. This is similar in construct to local routines, described in section 4.1.1 Definitions.
Performable global routines are created by right-clicking on the system folder, ‘Performed Global Routines’, and clicking ‘Insert Performed Glb Routine' from the context menu.

A dialog box is presented for the entry of the name and description. This process is similar to that shown earlier in Figure 13-1 and Figure 13-2.
The options of the performable routines are similar to the options as seen earlier in Figure 13-3; there is one additional option, ‘Call conditions’. This specifies what happens to the locally defined variables when the routine is called multiple times by the same program.


Figure 13-5: Global ‘performable’ routine code
It is also possible to define and use prints and files inside global performable routines. The way of designing print-layouts and file-layouts is exactly the same as it is for Reports, and this is detailed later in the training.
A print action executed in a global performable routine concatenates the data to the print file of the parent and the print is automatically closed when the performable ends. The print automatically closes and prints when the calling report or form is ended.
When a file is used inside a global performable routine, the file remains open until the file is closed by the ‘file.close’ command or at the end of the execution of calling form or report.
The command ‘exit module’ ends the current performable routine immediately, (see 4.2.6 Exit).

### Global DLL routines
Global DLL routines only differ from performable global routines in that these can be called by external programs, (i.e. a Windows DLL).
DLL global routines are created by right-clicking on the system folder ‘DLL Global Routines’, and clicking ‘Insert Dll Glb Routine' on the context menu. A dialog box is presented for the entry of the name and description. This process is similar to that shown earlier in Figure 13-1 and Figure 13-2.
The options of the global DLL routine are exactly the same as those for performable global routines.
The code editor is also no different to that seen earlier in performable global routines in Figure 13-5.
Changes and/or additions are only available after checking in the new code.
A global DLL routine allows its functions to be called from any programming environment. It is an ideal method to open up functions of the AMT LION application to other programming environments.  When calling a DLL function from another language the function name ‘main’ is used.
Calling non-main routines in global routine DLLs is also possible when using both the DLL and report/form objects in the same application. To call non-main routines it is necessary to declare a routine public in the global DLL routine which then allows it to be called in reports or forms by using a public routine call.

At generation time a further function ‘FREE_PCHAR’ is created into a DLL. This function is needed in other languages to clear the memory resources after a function call. At generation time typecasting to external programming environments is automatic, as follows:

- 44.1 An alpha becomes ‘Pchar’
- 44.2 A string becomes ‘Pchar’
- 44.3 A boolean becomes a boolean
- 44.4 An Integer becomes INT64 (64 bits)
- 44.5 Decimal becomes ‘Tnumeric’

The command ‘exit module’ will end the current DLL routine immediately, see 4.2.6 Exit.
The system item SI-PARAM can be used to pass parameters to the routine and to receive results.
The status of the CALL command is stored in the system item GETLASTRESULT.  If the CALL is executed successfully, GETLASTRESULT is empty.
For an example of a call to a global/external DLL, see figure 13-6.
Global routines can be also called from another application using following syntax:
<application>.<Global_Routine_DLL> ([<Parameter list>])
### External DLLs
DLLs created externally can be used same way as global DLLs.
In order for LION to track where external DLLs are used, as well as display proper relations, we need to create an external interface object.
To create an external interface object:
Open the folder for the application to which you want to add the external interface definition.
This is done from the Repository window. Select the folder "External Interfaces”, which is a subfolder of "Types", right-click and select ‘Insert External Interface. A dialog box is displayed:
Figure 13-6: Includable Global variable

Specify the options for the external interface definition in the displayed window. The name of the External Interface definition should be the same as the external library name.

In the type panel, you define the type of Type that you want to create, at the moment there is only the type External Interface available. If you selected the subfolder that indicates the correct type when calling the dialog box, this type will be selected automatically.

In the example below, an external interface object named ‘CSharpExternalLibrary is created and defined:
Figure 13-7: Includable Global variable

Below is an example call to an external or global DLL:
Figure 13-8: Includable Global variable

Here is example of C# code for an example of a DLL call used above:
namespace CallTest {
public class TestObj {
public static String CallMethod (String input) {
return "Hello, This is a test of a Call in AMT." + input;
}
}
}


### Includable global variables
Includable Global Variables are similar to Insertable Global Variables with the exception being the place in the code that they are inserted. Includable Global Variables are inserted in the definition section of a form or report. This can be the Variable, Constant, Retained Var or Boolean area.
When a new Includable Global Variable is added, a blank screen is presented.
Variable definitions can be entered. The syntax can be checked before the routine is checked in to the Repository.


Figure 13-9: Includable Global variable

The code doesn’t have to be syntax error free. When the code of the routine is inserted in the definition section of a form, report or global performable, the syntax is checked in the object where the routine is called.

The code in the example of Figure 13-10 is not error free, the ‘end_structure’ is missing.


Figure 13-10: Includable Global variable code

When the routine is inserted in a form, the syntax is correct when the missing ‘end_structure’ is defined in the form.


Figure 13-11: Global ‘Includable’ added in code


### Startup and Closedown
In AMT Developer Studio, there are two reserved names for performable global routines. These are ‘startup’ and ‘closedown’.
The AMT runtime environment at the moment that the first application service becomes active automatically executes the global performable routine ‘startup’. However, if the last application service shutdown was not a regular shutdown, then the ‘startup’ routine is not executed.
The routine ‘closedown’ is automatically executed by the last application service of the AMT runtime environment in a regular application shutdown.
It is not mandatory that the performable global routines ‘startup’ or ‘closedown’ exist in an application. If they do not exist, then nothing is executed.

### Routine parameter passing
Objects that are calling a routine can pass information to the receiving routine through parameters.
This mechanism of parameter passing is valid for all routines, not only for global routines. Local routines in forms and reports can also make use of parameter passing.
Routine parameters are declared in the routine’s header. The example syntax below is from a performable global routine ‘grp_country’.
Example syntax:
routine main (country_code : alpha 3)
begin_routine
gtq_country.index (idx_country_code)
gtq_country.equal (country_code)
gtq_country.getfirst ()
if resok
get_desc ()
endif
end_routine

Routines can have multiple parameters defined in the routine header with each parameter separated by a comma.  In the example syntax above the parameter to pass to the routine is the country code.

When calling the routine, the parameter does not have to have the same name.
Example syntax:
if cntry_code <> ''
grp_country (cntry_code)
endif

Parameter(s) can also be defined as dictionary item(s).

Example syntax:
routine main (vn-custno : dct cust-no)
begin_routine
if vn-custno <> 0
get_customer_details ()
endif
end_routine



#### Optional parameters
Parameters may be setup as optional, so that they are not always provided. Optional parameters are always defined after implicit parameters, and are defined with the keyword ‘optional’ immediately after the length of the parameter declaration.
Example Syntax:
routine Search1 (custno : numeric 8, postcode : alpha 10 optional)

routine Search2 (custno : numeric 8, postcode alpha 10
optional, city : alpha 30 optional)

When calling routines with optional parameters, the optional parameters are filled from left to right. For example, calling ‘Search2’:

Search2 (12345, ‘7740AD’)

Passes ‘12345’ to the ‘custno’ parameter and ‘7740AD’ to the ‘postcode’ parameter, with city NOT being passed as a parameter value.


#### Result value
Routines can also be used as a function that provides a result.
In the following example, the value of the result is passed to the reserved system variable ‘result’. The definition of ‘result’, like parameters, is declared in the routine header. The following is an example of a performable global routine ‘grp_customer_detail’ that returns a boolean result.
The data type of the returned data is declared on the ‘routine’ declaration code line following a colon.
Example Syntax:
routine main : boolean
begin_routine
result := false
get_customer ()
if vn_cust_no <> 0
result := true
endif
end routine

When a routine returns a boolean value this routine can also be called within an if statement
Example syntax:
if grp_customer_detail ()
fill_form ()
else
exit
endif

An ‘exit’ in a global routine, like in a local routine, only ends the current routine, (see section 4.2.6 Exit).
When a routine returns a numeric or alphanumeric value the result can be passed to another variable following the normal assignment rules, see the example below.
Example routine ‘get_country_name’ returning an alpha 30:
routine main(code : alpha 3): alpha 30
begin routine
gtq_country.index (idx_country_code)
gtq_country.equal (code)
gtq_country.getfirst ()
if resok
result := gtq_country.country_name
else
result := ‘’
endif
end_routine

This routine can be called in a normal assignment statement:

va-country-name := get_country_name (country_code)
## Relations
Included in the navigation tree of every object you will see the option ‘Relations’. This option shows an overview of all relations that an object has with other objects, (see Figure 13-12).


Figure 13-12: Relations

Relations are maintained by the AMT Developer Studio automatically.
In the furthest left column is listed the ‘Source Object’, and on the right is the ‘Target Object’, see Figure 13-12.
The columns between the Source and Target Object indicate the kind of relationship. Some of these are only indicated after the object is generated.



Exercise 11: Using routines.
# List box and combo box
## Adding a listbox

A list box is a visual control displaying data in a list that the end user can select from at runtime. The user can only select one value from the list, either by clicking, or double-clicking an item.
The list box can be setup either at design time from the Object Inspector, or dynamically at runtime from the implementation code.
To create a new list box on the screen layout canvas click the ‘Listbox’ button , and click on the screen layout where the list box is required, (see Figure 14-1).



Figure 14-1: ListBox

The list box can be sized so that all the items can be viewed, or at runtime if the list is greater than its size then vertical scroll bars are automatically added. Optionally, the properties can be set to add horizontal scroll bars.


To create the list at design time, click on the property ‘Items and Values’ selection button. This opens the ‘Items and Values’ dialog box, as seen when creating a radio button. This is completed exactly the same way as described in section 3.4.13, (i.e. the value added in the ‘Item’ section is the value that is seen by the end user in the list box, and the value entered in the ‘Value’ section is the actual value that the application sends when the user clicks on the item in the list). The value that is sent is always the line that the end-user selects.
Both list and combo boxes have a property ‘sorted’. If this property is set to true, the items and values are sorted and displayed at runtime in alphabetical order.
List boxes can also be populated dynamically at runtime, (see section 14.3 Runtime list boxes and combo boxes).

## Adding a combo box
A combo box is a visual control that allows the end user at runtime to select an item from a drop down list by clicking on it, or by double clicking on it. A property in the Object Inspector can be set, so that the end user can also freely enter data manually in the combo box field.
To create a combo box, click the ‘Combobox’ button , found on the standard screen layout toolbar, then click on the screen layout canvas where the combo box is required, (see Figure 14-2).


Figure 14-2: ComboBox

By default, a combo box ‘style’ is a ‘Drop down list’, (see Figure 14-2). If the ‘Style’ property of the combo box is changed to 'Drop down' then it is possible to both select lines from the combo box, or to enter data manually. By setting the property ‘ValidateEntry’ to true, a validation is performed at run-time to control that the value manually entered exists in the value list of the combo box. This validation is executed before the routine ‘process_main’.
The values and items are created in exactly the same way as described in the previous List Box section, and like the List Box, these values and items can be created dynamically at runtime.

## Runtime list boxes and combo boxes
The values and items of a List Box or Combo Box  control can be created dynamically at runtime. This can be done in one of two ways. The first method, covered in this training, creates or uses a file to populate the control. The second method fills the list/combo box at runtime from memory.

To create or use list/combo box files at runtime the property ‘MemoryBased’ in the Object Inspector must be set to false, (see Figure 14-2). Two other properties within the Object Inspector, ‘ItemsDisplayed’ and ‘ValuesSend’ need to be also set, (see Figure 14-2). The default values are ‘2’ for ‘ItemsDisplayed’ and ‘1’ for ‘ValuesSend’. The commands ‘fillbox’ and ‘attachtobox’, described in the following sections, interpret these values to create the items/values in the control.

### Fillbox
The ‘fillbox’ command is used to create a file of ‘items’ and ‘values’ at runtime, that are used to fill a list/combo box. The command’s structure is as follows:



Figure 14-3: FillBox

The ‘fieldname’ is the name of the file to be created, and can be specified in one of two ways.
If the ‘fieldname’ is in the format, <form name>.<field name>, (e.g. ‘country.combo_cntry_code’), then only the control specified ‘combo_cntry_code’, in the form specified ‘country’, will be automatically populated with the contents of the list/combo box file.
If the fieldname is in the format ‘*.<field name>’, then any form with a list/combo box of the same name as the ‘fieldname’ will be automatically populated with the values of the list/combo box file. Due to the fact that an asterisk cannot be used in a windows file name, the actual name of the file created will be an underscore and the extension will be the field name specified, (e.g. ‘_.combo_cntry_code’).

The ‘value’ is the string to be added in the list/combo box file. The ‘value’ begins first with a character that defines the delimiter character. Ensure that this delimiter used is not a character that is likely to appear in either the item to be displayed or the value to be sent, as this causes truncation. After the first character, the ‘value’ then consists of two parts separated by the specified delimiter. One part contains the item to be displayed to the end user, and the other contains the value to be sent to the application code, (see Figure 14-4).
For the first ‘fillbox’ command in a transaction, the previous contents of the list / combo box are cleared and a new contents file is built with the first value specified. Subsequent fillbox commands then append the value specified to the list/combo file.
In the example below the pipe character, ‘|’, is first defined as the delimiter, then the country code on the left of the second pipe character is the value that is sent to the application code, (gtq_country.cntry_code), and the value to the right, (gtq_country.cntry_name) is the value displayed to the end user in the list/combo box.  The fieldname is defined as ‘*.combo_cntry_code’, to allow the file to automatically populate any list/combo boxes with the same name in other forms.

Example syntax:
gtq_country.index (idx_cntry_code)
gtq_country.start ('')
loop gtq_country
va-40 := '|' & gtq_country.cntry_code
va-40 &= '|' & gtq_country.cntry_name
fillbox ('*.combo_cntry_code', va-40)
endloop


If no ‘fillbox’ command is encountered in the form’s code, but there is a list/combo box on screen, then any previously existing filled contents file is used for displaying the data.

The Contents File

The contents file can be viewed in a text editor. The file is located in the ‘lbx’ directory that is defined by the system administrator in the AMT Control Center.  An example of the country file can be seen in Figure 14-4.


Figure 14-4: ComboBox file content

### Attachtobox
The statement ‘attachtobox’ is used to attach an existing contents file, of any name, to a list/combo box on a form.


Figure 14-5: AttachToBox
The file name that is provided in the second parameter should have a valid contents file layout for the list/combo box.
Example syntax:

attachtobox (si-currform & '.coll_combo_cntry', 'ctry.combo-cntry-code')
Exercise 12: Use list and combo boxes.

# Application management
## Multiple generation sets
Within one application, sources can be defined in more than one generation set.
This can be setup in such a way that a ‘development’ generation set holds all the revisions of development, and a production generation set contains all the revisions running in the production environment. This helps to keep track of code revisions running in production, while updates are being worked on, and tested, in a development or staging environment.
It is possible to set up as many generation sets as required, (e.g. a set for system acceptance testing, a set for user acceptance testing, etc).
The AMT Developer Studio Generator always performs the generations for the generation set that the developer is logged into.
The generation sets are defined in the ‘GS’ view of the AMT Developer Studio, (see Figure 15-1). The most important setting from this view is the ‘Source Folder’, which defines the folder into which the Generator places its results and files.


Figure 15-1: Generation Set
Generation sets are defined and maintained by an AMT Developer Studio Administrator.

## Logging on to another generation set
When more than one generation set for an application exists, a dialog box appears when a developer first tries to access the application in the repository view, asking which generate set to use, (see Figure 15-2).



Figure 15-2: Logon to Generation Set
A check box ‘Default’ is provided. It is probably best to check this with the ‘Development’ generation set selected. This way, by default, the development generation set is opened when first accessing the application.

The generation set that a developer is logged on to is always displayed in the caption of the tab-sheet, (see Figure 15-3).


Figure 15-3: Logged on Generation Set

If a developer wishes to switch to another generation, then click the speed button ‘Choose Generation Set’  on the AMT Developer Studio tool bar, (see Figure 15-3). This will recall the dialog box seen in Figure 15-2, for selection of another generation set.
After choosing the other generation set, the title bar changes to the generation set chosen, and the list of revision ids now shown are those that are currently in this generation set.

## Revision control
Revision control offers developers full version control over their application. All objects, (e.g. forms, reports, tables, indexes, global routines, and system options, in the AMT Developer Studio repository are identified by a revision id).
When a new object is created, AMT Developer Studio automatically assigns the revision-id ‘1.0’.
Each time an object is checked-in, the revision-id is automatically incremented with 0.1, so typically a revision history of an object will be 1.0, 1.1, 1.2, 1.3 etc.
All revisions are stored in the AMT Developer Studio repository; not only the latest, so at any time any revision of an object can be made available again.
The AMT Developer Studio repository consists of three logically different parts.
- 51.1 The version bank. In this part are all checked-in revisions of objects.
- 51.2 Working storage. Each developer has their own working storage area. All ‘save’ actions that the developer does are in storage in this area.
- 51.3 AMT Data. Things such as security, generation requests, locking information, generation sets, etc. are stored in this area.


Figure 15-4: Repository

## Revision control view
Entering ‘REV’ in the open command box opens the Revision control view, (see Figure 15-5).


Figure 15-5: Revision view

The revision control contains tab sheet(s) for different types of objects. This list is made up of the following columns:
- 52.1 The ‘Name’ of the object
- 52.2 The ‘Description’ of the object
- 52.3 ‘Revision’ currently assigned to this generation set
- 52.4 The ‘State’: This column is blank unless the object is locked, when the word 'locked' appears in the column (or, alternatively a higher revision id exists in the version bank, then the highest revision id is indicated in this column)
- 52.5 ‘Date/Time Checked In’ is the date and time of last check-in for the last  revision
- 52.6 The ‘Locker’ column is blank, except when the object is locked, at which time the Windows logon id of the locker is shown in this column
- 52.7 The ‘Revision Comment’ is the short description that was provided at last check-in
- 52.8 ‘License’ indicates the number of lines in an object (when the AMT LION license is for a limited number of lines)
- 52.9 The ‘Label’ column is blank unless an object is brought into this generation set by means of a label, in which case the label name is displayed
- 52.10 The ‘Date/Time Locked’, is the date and time that this revision was locked.

The columns displayed in the revision view can be changed by right-clicking oneport the column header and selecting or deselecting the column name from the context menu that appears, (see Figure 15-5).
The ‘Selection’ combo box (see Figure 15-5), allows further filtering so that only ‘objects in this generation set’ are displayed, or alternatively only ‘objects not in this generation’.
The ‘State’ combo box, (see Figure 15-5), allows filtering as follows:


### Revision control function buttons
#### Get newest
The ‘Get newest’ button can be used to retrieve a higher revision of an object (when a more up to date revision is available in the version bank).
Selecting the object(s) and clicking the ‘Get newest’ button brings the highest revision into the current generation set. The highest revision id is then displayed in the revision column, and the state is now be blank.
Note that this only brings the highest revision into this generation set, it does not mean that the application runtime is using the latest revision. For this to happen the newest revision must be generated against this generation set.


#### Get all newest
The button ‘Get all newest’ should be used with care. Clicking this button will compare all the objects revisions in the version bank with the revisions in the current generate set, and will bring all the highest revisions into the current generate set. This too only brings the highest revision into this generation set; it does not mean that the application runtime is using the latest revision.

#### Edit (Lock)
Clicking the ‘Edit (Lock)’ button puts the selected object(s) into ‘edit mode' and locks it from editing by all other developers.
The object(s) are now 'checked-out' of the version bank and a new copy placed into the working storage of the developer.
Only the developer that locked the object can now modify it. All modifications the developer now does to the object are done on the object that is in their working storage, not the revision in the version bank.
Objects that are locked can be viewed, but not edited, by other developers. In the ‘General’ tab sheet of ‘Personal Options’ is a checkbox ‘View changed source of locked objects’, (see Figure 15-6). When this option is checked a developer, can see the locked revision of other developers, but not change them. If this option is unchecked, then the developer only sees checked in revisions from the version bank.



Figure 15-6: View changed source of locked objects


#### Check in
The ‘Check in’ button, as seen in section 7.2 Checking in Objects, is used to check modified object(s) back into the version bank. When a 'locker' checks the object(s) back into the version bank, it is assigned a higher revision number, and this revision is then added to the version bank.
At this same moment, the copy that was in the working storage of the developer is discarded. The object(s) are now no longer locked, and can be locked again by other developers.

#### Unlock
If a developer wishes to undo and discard all changes made to an object, since locking it, then the object(s) are selected and the ‘Unlock’ button clicked. The developer then receives a confirmation message to unlock the object, (see Figure 15-7).


Figure 15-7: Unlock object dialog

Upon clicking the ‘Yes’ button, the locked revision in the version bank is unlocked, and no new revision is stored in the version bank. The copy of the current revision in the developer’s working storage is discarded. The object is then available again for another developer to lock.


#### Delete
Objects can be deleted from the current generate set with the ‘Delete’ button.
After selecting the object(s) to delete and clicking the ‘Delete’ button, the developer receives two confirmation messages. The first asks if they are sure that they want to remove the object from the generation set, (see Figure 15-8).


Figure 15-8: Delete object dialog

Clicking the “Yes” button, only deletes the object(s) from the current generate set, not from the AMT Developer Studio repository.
The second confirmation asks if the object(s) should be deleted from the AMT LION repository, (see Figure 15-9).



Figure 15-9: Confirm deletion from repository

Clicking the ‘Yes’ button deletes the object(s) completely from the AMT LION repository. The request is granted if the object(s) are not locked in another generate set.
If an object is deleted from a generate set only, then this is indicated in the revision control view in the ‘Revision’ column with the word ‘Deleted’.
To recover a deleted object from another generation set, click the ‘Get newest’ button.
The button ‘Get all newest’ does not recover objects that are deleted from a generate set.
Objects can only be deleted in the revision control view. They cannot be deleted using the repository view.


#### Revision history
Selecting an object and clicking the button ‘History’ opens a dialog box listing all the revisions that are available for that object in the version bank, (see Figure 15-10).


Figure 15-10: Revision history

Get Revision
To retrieve a revision into the current generate set select the revision then click the ‘Get revision’ button. The dialog box closes and returns to the revision control window, where the revision selected is now displayed as being within this generation set. Like some of the other revision functionality, this only brings the revision into this generation set and does not mean that the application runtime is using this revision.

Differences
To show the differences of two revisions, select the two revisions while pressing the ‘CTRL’ key, then click the button ‘Differences’. A check box is also provided to ‘Ignore case’ differences.

The ‘Show Differences’ dialog box then opens, highlighting where the differences are, (see Figure 15-11).


Figure 15-11: Revision differences

By default, the contents on the left display the older revision, with the more recent revision on the right. Different versions can be selected from the drop-down box with the ‘V’ button. Differences are highlighted in the color of the revision, (i.e. yellow or green).
The default view shows the differences ‘Side by Side’, and if this check box is unchecked, the differences are shown together in one view.
The line numbers can be removed from the display by unchecking the ‘Show line numbers’ to provide a greater display space, (see Figure 15-11).
The buttons on the left allow for jumping to the ‘Previous’ or ‘Next’ difference, or the ‘Previous Block’ or ‘Next Block’ of differences.
At the bottom of the display is a drop down list box, the options available within the box change depending on the object being viewed. If the revision differences of a form are being shown, then the default display is the ‘Code’ differences, but the differences of any element of the form can be displayed, (e.g. screen layout, options, etc).

In Figure 15-12 the ‘Display’ shows the ‘Screen layout’ differences of the form. No differences exist, and this is confirmed in the left-hand margin of the window.


Figure 15-12: Option differences

2-way Merge and 3-way Merge
This option makes it possible to merge changes that are applied in a branch. This is explained in more detail in section 15.9 Branching.

Compare With
With this action, two different objects can be compared. The objects need to be of the same type, (e.g. CUSTOMERS with CUSTOMER_COPY).

Split By GenSet/List Gensets
Pressing this button will toggle the display between listing GenSets on the same line and listing them one under another across multiple rows.
If the version is active across many GenSets then there may not be room to display them all easily on the form.  Splitting them across multiple rows make the version information easier to see.


Ignore Case
The "Ignore Case" checkbox on the Revision history screen sets the default 'Ignore Case' behaviour for the 'Differences...' Window.
Expand All
The expand all checkbox shows all nodes within the version tree regardless of whether they are in the GenSet that the user is currently viewing or not.  This will help with version analysis and removes the requirement to click each branch open one at a time.

#### Assigning a label
This button assigns the selected object(s) in the Revision view, (see Figure 15-5), to a label. This label can then be used to move revisions from one generation set to another, and to track this movement. This is covered in further detail in section 15.11 Labels.

#### Promote to revision
Sometimes it’s necessary to assign a new revision id to object(s). For example, it may be required that all the objects have the same revision id for a release, to help keep track of releases. Only revisions that are checked in can be assigned a new revision. In Figure 15-13 all the application forms have all been selected by using the Windows shortcut ‘CTRL’ + ‘A’.


Figure 15-13: Select all objects

By clicking the ‘Promote’ button, the ‘Revision comment dialog box appears, (see Figure 7-14). Here the new revision id and comment is entered. Once the ‘Ok’ button is clicked, the revision id and comment is then assigned to all the selected objects, (see Figure 15-14).


Figure 15-14: Revision comment assigned to all objects
#### Grant lock
Normally when two developers want to maintain the same object, the first one has to lock the object, finish their work, and check the object in. The second developer can then lock the object, start modifying it and check it in again. This process results in two new revisions.
Some organizations have a policy not to create revisions that never go into production; this is where the ‘Grant Lock’ button helps.
By selecting the object(s) and clicking the ‘Grant Lock’ button, the ‘Grant lock to user’ dialog box appears with a list of all the developers, (see Figure 15-15).


Figure 15-15: Grant lock

A developer can then select another developer to transfer their lock on the object(s) to, and click the ‘Ok’ button.
Using this way of transferring a lock, does not check in a revision of an object. All that happens is that the object(s), and all the saved changes done to it by the first developer, are transferred to the other developer’s working storage.

#### Branch code
This is explained in section 15.9 Branching.
## Revision Control using the Repository View
A number of functions that are available in the revision control window are available also from the repository view from a popup window, (see Figure 15-16).
To access the popup menu, select the object(s) to perform revision control on and right-click. The popup menu appears with the item ‘Revision Control’ with a number of sub options for performing revision control.


Figure 15-16: Revision control from repository view

## Revision Control using the Generate Release View
The Generate Lion Release/Patch/Fix shows the differences between all generations sets in just one view. This view can be called by the menu option “ViewGenerate Release” or by ‘GENREL’ in the open command box.


Figure 15-17: Revision control from release generate


Click on the button ‘Revision management’ to show all differences between the checked application and generation sets.


Figure 15-18: Show revision differences in Generation Sets

The view can be sorted by clicking on the column heading. Columns can be moved by dragging them to a new position.
All checked versions in all generation sets are synchronized with the ‘Get newest’ button.
The generate button on the dialog box as shown in Figure 15-17 will request a generation for the checked generation sets. The objects to be generated can be specified by using the drop down box:
- 54.1 Whole App
- 54.2 Changed Obj
- 54.3 Application
- 54.4 Database
- 54.5 Global Definitions
- 54.6 All Forms
- 54.7 All Reports
- 54.8 All Dlls
- 54.9 All Perf

Only System Administrators have access to this function.
## Lock view
Entering ‘LOCK’ in the ‘Open’ box presents a view of all objects for this application that are ‘Locked’ by the current developer, (see Figure 15-19).
By selecting different options in the drop down lists the view can be changed to ‘All users’ that have objects locked, and to view ‘All Applications’. Other options include: ‘Check in’, ‘Unlock’, ‘Revision history’, and ‘Grant Lock’.



Figure 15-19: Locked objects
## Code line revisions
Right-clicking in the code editor opens a popup menu.  Click ‘Show Revision’, and the revisions detail choices are shown, (see Figure 15-20).


Figure 15-20: Revision in code view


Selecting ‘All’ displays a timestamp for each code line, the user that created/changed it, and revision details for that line of code, (see Figure 15-21).


Figure 15-21: Revision in code view displayed
## Branching
Sometimes there is a need to make changes to an older revision of an object instead of the latest revision.
For example, a number of objects may be being changed (or have changed) in development for a future release. These objects have a higher revision id in development than that currently running in the production environment, and can only be released on a specific date.
Were a production problem to arise, in one of the objects that is part of this future dated release, then the object could require an immediate correction. The revision in production is not the latest revision, and changing the latest revision in development will require the removal of the changes made for the pending release.
Once the production correction is applied and promoted into the production generation set, a further revision then need to be created to re-apply the changes for the pending release.
The particular production correction may no longer be valid for the future release, and so this may require removing again.
A typical release tree is shown in Figure 15-22.


Figure 15-22: Typical release flow

Branching makes this scenario easier. This allows the developer to create a branch against the older revision that is currently in production. The correction to the production problem can be applied to the branch and checked in and released to the production environment. This is demonstrated in Figure 15-23.


Figure 15-23: Branching
The future dated revision, which contains all the changes required for this future release, can then be brought back into the development generate set. The ‘quick fix’ can be applied, if needed, to this future dated release revision so that the problem isn’t re-introduced in the future release.

### Creating a branch
To make changes to an older revision, either access the older revision directly in a generate set that holds that revision, or alternatively bring the older revision into the current generate set, by selecting it and clicking the ‘Get revision’ button in the Revision History dialog box, (see Figure 15-10).
Once the older revision is in the current generate set, it needs to be locked for the correction to be applied. On attempting to lock this older revision, AMT Developer Studio recognizes that a lock is being attempted on a revision that is not the latest and generates an error message. The object must be branched using the ‘’Branch’ button as shown in Figure 15-24.


Figure 15-24: Branch an object

Note that the version created is 1.5.1.1. The branching process consists of two steps. First, a branch version 1.5.1 is created and then the object is put in edit and version 1.5.1.1 is automatically applied to the developer’s generation set.

It is possible to create a second branch on the same version. This process is shown in Figure 15-25.


Figure 15-25: Multiple branches

Remember that any changes made to this older revision are not automatically taken into future revisions. These will, if required, need to be applied to the latest revision, which may also need bringing back into the current generate set.
It’s also possible to create a branch of a revision that is already a branch.
All branches are indicated in the history overview as shown in Figure 15-26.


Figure 15-26: Branch overview

### Merging
There are two ways to merge changes:
- 57.1 3-way merge; to merge changes made in a branch into the main stream
- 57.2 2-way merge; to merge changes in the main stream revisions into branched versions


Figure 15-27: 3-Way merge example

In a 3-way merge, the final version (in the middle) is constructed from the changes in the branch on the left and the latest version on the right. With the buttons on the top of the window, changes can be moved into the locked version.
The color in the tab-sheets at the top indicate the differences:
- 57.3 Green - no differences
- 57.4 Orange - differences processed by developer
- 57.5 Red - differences needing attention


There are also two options to merge the change automatically.
- 57.6 Per tab-sheet by using the left-most button in the middle window.
- 57.7 For all tab-sheets by using the ‘Auto Merge’  button on the bottom of the screen.
After confirming the changes with ‘Ok’, the object can be opened and generated.


Figure 15-28: 2-way merge example

In a 2-way merge, changes made in the mainstream can be brought into the locked branched version in the same way as a 3-way merge.
For more information on 3-way merging, watch this video.


## Folders
Folders can be used to group objects for ease of maintenance, and the applying of revision control functions in one action.

### Create a folder
To create a folder, in the repository view right-click on the application where the folder is required. This presents a popup menu, (see Figure 15-29).


Figure 15-29: Create folder

From this popup menu select the option ‘Insert Folder’, which then opens a dialog box, for entry of the folder name, (see Figure 15-30).


Figure 15-30: Create folder dialog
Upon clicking the ‘Ok’ button, the folder is created, and it can now be given a short description, (see Figure 15-31).


Figure 15-31: Folder created

The documentation section also allows for adding more detailed information about the folder. Create a documentation section by right-clicking on ‘Documentation’ and from the popup menu selecting ‘Insert’.
After entering any details save and close this window. Upon returning to the repository view, the new folder can now be seen, (see Figure 15-32).


Figure 15-32: Folder in repository view
### Create a shortcut into a folder
It is possible for a developer to create shortcuts pointing at the actual objects in system folders.
To create a shortcut in a folder that points to an existing object, first select the object(s) that must go in the folder, and either ‘drag and drop’ the selected object(s) into the folder, or alternatively right-click and from the displayed popup menu, select the option ‘Create Shortcut into Folder’, (see Figure 15-33).


Figure 15-33: Create shortcut into folder
Right-click on the folder into which the shortcut(s) must be placed and select from the popup menu the option 'Paste Shortcut', (see Figure 15-34).


Figure 15-34: Past shortcut into folder
The shortcut is now available in the folder, (see Figure 15-35).


Figure 15-35: Shortcuts in folder created
Shortcuts can be placed in folders for various object types, (e.g. forms, reports, tables, indexes global routines, etc).
It is possible to create new objects directly in a user-defined folder. If this is done, then both the shortcut in the selected folder and the actual object in the system folder (displayed in red) are created simultaneously.

### Deleting shortcuts and folders
A shortcut in a folder, or a folder itself, can be deleted. This action can be performed in the repository view, unlike deleting an object. When deleting a folder, any shortcuts within it are also deleted. AMT Developer Studio of course, only deletes the shortcut(s), not the object(s) themselves.
If the object is locked the status of the object is unchanged by the deletion of the shortcut, (i.e. it remains locked).
To delete a shortcut, right-click on the shortcut and select ‘Delete Shortcut’ from the popup menu, (see Figure 15-33).
To delete a folder right-click on the folder and select ‘Delete’ from the popup menu, (see Figure 15-34).
### Folder revision control
After creating a list of shortcuts in a folder, the revision control can be applied in one action to all the objects with a shortcut within the folder. This is done by using revision control at the folder level, to ‘Check In’, ‘Edit’, ‘Unlock’ or ‘Assign Label’. To do this, right-click on the folder to bring up the popup menu and choose the option 'Revision Control' and the function required, (see Figure 15-36).


Figure 15-36; Check in through folder

So, for example a developer may set up a folder with shortcuts to all the objects required for a project. In one action at folder level the objects can be locked so there is no risk that another developer will try to lock those needed objects.
The developer can then make changes and once complete the developer can then  (in one action) check in all the changes, contained in the folder, and assign a revision comment.
The developer now knows exactly what objects are required to release the project to another generation set, either a test environment, or directly to production environment, as they are listed in the folder. It is not only the objects required that is shown in the folder, but also the specific revision-ids of these objects.
## Labels in the Repository
Labels in the Repository are used to move revisions from one generation set to another, and track this movement.

### Assigning a label

To assign revisions to a label, access the generate set where the revisions exist that need to be moved, (e.g. Development).
Revisions can be assigned to a label in many ways:

- 59.1 In the Revision view, by selecting the objects to assign a label and clicking the ‘Label’ button, (see section 15.4.1 Revision control function buttons)
- 59.2 In the Repository view, by selecting the objects and right-clicking and selecting from the popup menu ‘Revision Control’ and ‘Assign Label’, (see Figure 15-16)
- 59.3 In a folder, by right-clicking on the folder, and selecting from the popup menu ‘Revision Control’ and ‘Assign Label’, (see Figure 15-36)

Whichever method is used, a dialog box is then presented to select the label that revisions should be assigned to, or to add a new label, (see Figure 15-37).



Figure 15-37: Select label dialog

Upon clicking the button ‘New’ a further dialog box is presented to add the label name, (see Figure 15-38).



Figure 15-38: Create label dialog

After entering the label’s name, click the ‘OK’ button. The label is then added to the ‘Select a Label’ dialog box. See Figure 15-39, where ‘Testing release 1’ is entered as the label name.


Figure 15-39: Label added to label list

Now select the label and click the button ‘OK’ to assign the previously selected revisions to this label.

The label assigned to a revision can be seen in the Revision view, (see Figure 15-40).

Figure 15-40: Labels in revision view

### Label management
The ‘Label Management’ view is accessed, by typing ‘LAB’ in the open command box and pressing enter. From here labels can be created and maintained, (see Figure 15-41).


Figure 15-41: Label view

The object revisions assigned to a label can be seen in the ‘Label Management’ view. The column ‘Revision’ shows the revision id that belongs to the label.
The column ‘Current Revision’ shows the revision id assigned to the current generate set.
Should object revisions need removing from the label, then select the object(s) and click the ‘Remove’ button.
From here the labels can also be added by clicking the ‘New’ button and entering the label name in the label edit box. Once the name is entered, click the ‘Ok’ button. The label is then added into the label list, (see Figure 15-41).
Label names can be changed by clicking the ‘Properties’ button and selecting ‘Edit’.

To delete a label simply click the ‘Delete’ button and confirm the deletion.
Label Management generates logs for verification and auditing.

### Move a label into another generation set
After selecting the correct Generation Set, the versions can be moved into the GS by right-clicking and selecting ‘Assign selected to generation set XXXX’. The label of the button depends on the selected GS.
The changed objects will automatically be flagged for generation.

Figure 15-42: Move objects through label

Upon clicking ‘Yes’ all the selected revisions from the label are moved into the current generate set, and the ‘Current Revision’ column will now be the same as the ‘Revision’ column for those selected objects.


## Log
The ‘Log’ view is accessed, by typing ‘LOG’ in the open command box and pressing enter. The log view shows the activities of developers within an application, (see Figure 15-43).


Figure 15-43: Log view

From here the movement of labels can be viewed, and the revision objects that are moving from a label to a generation set.
The selection can be filtered by selecting a ‘Show log of’ date and a ‘Generation set’
The displayed information consists of:
‘Time’	 	The time of the log entry
‘Station’		the station the change to the generation set was made from
‘Generation set’	the generation set this log entry belongs to
‘Message’		the description of the change this log entry is for.


Exercise 13: Become familiar with folders and revisions.

# Reports
Reports consist of three different types, ‘Application’, ‘Insertable’ and ‘Template’.
Like Forms, the end user application uses reports from the folder ‘Application Reports’. The folders ‘Insertable Reports’ and ‘Template Reports’ are for development purposes.
Print output can also be defined within an application form. This is created in a similar way to that described in the following sections.
## Create a new application report
‘Application Reports’ are created in a similar way to ‘Application Forms’, (see section 3.2 Creating a New Application Form). To create a new application report, in the repository view right-click on the folder ‘Application Reports’ and select ‘Insert Object’ and ‘Insert Report’.
A dialog box, similar to that when creating other objects, is presented for the entry of the report name and description, (see Figure 16-1).


Figure 16-1: Create report dialog

The report type can be selected, (i.e. a ‘Graphical Report’ or a ‘Text Report’).
A graphical report output allows for more options in the print layout than text reports. For the purposes of this training the following sections only cover text reports.


## Options
Once the name and description are entered, and the type of report selected, (e.g. ‘Text Report’), click the ‘OK’ button. The report is then created, and opened at the report options window, (see Figure 16-2).
The following options are for a text report:


Figure 16-2: Report options

### Printing options
Decimal Sign
The ‘Decimal Sign’ drop down can be used to specify the character, (‘Dot’ or ‘Comma’), that is used in decimal values. By selecting ‘Default’, the report uses the sign specified in the application options.

Separator Character
Use the ‘Separator Character’ to specify the separator character, (‘Dot’ or ‘Comma’), that is displayed between every three digits counted from the right in numeric values. By selecting ‘Default’, the report uses the sign specified in the application options.


Currency Sign
The “Currency Sign’ allows a character to be specified, which is used in items that have a specified type of ‘dollar’.

Maximum layout width
Specifies the maximum layout width of the print output in terms of number of characters.

Floating Sign
Numeric fields will normally be ordered in a column is such a way that the decimal separators are aligned to each other. Checking this option results in all numeric fields being left aligned.

Clear print fields after a Print
This option indicates that after the execution of a print command, all the edit fields in the layout are initialized, if unchecked then the values in the edit fields remain for subsequent print commands.  The option is checked by default.

Parameter Name
In the field ‘Parameter Name’ a variable can be declared that is used for parameter passing. This variable accepts the value that is passed as a parameter at runtime.

Recovery name def
The field ‘Recovery name def’ is a variable, or structure, that can be defined to save recovery information. The command SRN, (save recovery name), uses this variable/structure. This is explained further in section 16.7.6 Saverecoveryname.
.

### Database options
The database options are the same as those of forms and are explained in section 8.1.1 Table query read.
## Print Outputs
The ‘Print Output’ can be used to produce multiple report print outputs within one report.
The print output ‘PROUT’, which is automatically created by AMT LION developer, must be present in every report, (see Figure 16-3).
Further print outputs can be declared, by clicking the option ‘Add new printer output’, which then presents a dialog box for the entry of the name of the new print output, (see Figure 16-3).


Figure 16-3: Add print output
Once the name is entered and the ‘OK’ button pressed, the print output is created and added to the navigation tree under the print output ‘PROUT’.

### Print output properties
The auto completion function shows that there are numerous properties of a ‘print output’ that can be configured, (see Figure 16-4).


Figure 16-4: Print output ‘autocompletion’

Print output properties that may be of use in this training are explained below


‘Linesprinted’		This gives the number of printed lines on the current print output.
‘Maxlines’	Here the maximum number of lines to be printed on a page can be specified.
‘Pagesprinted’		This gives the number of printed pages so far.

## Print Layouts
‘Print Layouts’ define the print output of the reports.
To create a new print layout, click on the option ‘Add new text layout’. This then presents a dialog box for the entry of the print layout name, (see Figure 16-5).


Figure 16-5: Insert layout dialog

After entering the report layout name and clicking the ‘OK’ button, the report layout is added to the navigation tree on the left, and the report layout canvas is displayed, (see Figure 16-6).


Figure 16-6: Layout canvas
### Print layout visual controls
There are only two kinds of visual controls available for text report print layouts, label controls and edit boxes, (see Figure 16-6).
These visual control items are created in exactly the same way as they were on the form screen layout canvas, (i.e. by using the speed buttons provided, see section 3.4.3 Adding Labels).
A label provides for fixed captions in the report’s print output, the text for which can be specified in design time in the Object Inspector, or assigned at runtime. For these, the assignment remains after printing the layout, unlike an edit box.
An edit box is filled at runtime, and if the option ‘Clear print fields after a Print’ is checked, then the values assigned are automatically cleared out after printing the layout.
The print layouts in text reports, unlike screen layouts in forms, use character positions not pixels for the Object Inspector properties such as ‘left’ and ‘top’.

## Implementation and routines
The implementation is similar to that seen in forms and global routines, (see Section 4 - Writing Code within a Form).
Reports at minimum require one routine called ‘main’, after that, as many or as few routines as needed can be added.

## Assigning values to print layout items
Values are assigned to print layout visual controls in a similar way to assigning values to form screen layout visual controls.  The main difference in a report is  that if a visual control’s name is used in more than one print layout of the report, the print layout visual control must be prefixed with the print layout name.
Example syntax:
lay_heading.name     := ‘Report Title Text Here’
lay_address.name     := gtq_customer.name
lay_address.street   := gtq_customer.street
lay_address.city     := gtq_customer.city
lay_address.postcode := gtq_customer.postcode
lay_address.country  := gtq_customer.country
## Report Specific Code Commands
As print output can be defined in forms as well as reports, the following commands are available in most objects (some commands are exclusive to reports).

### Print
The ‘print’ command is used to send the content of a ‘layout’ to an output medium.


Figure 16-7: PRINT command

An optional value ‘line’ can be specified, which for text reports is the line on the page that the print layout must begin. If omitted, the ‘layout’ is printed on the first available line of the output.
The ‘output id’ is also an optional parameter. If no ‘output id’ is specified, then the print will default to the ‘Prout’ print output.

Example syntax 1:
lay_address.name     := gtq_customer.name
lay_address.street   := gtq_customer.street
lay_address.city     := gtq_customer.city
lay_address.postcode := gtq_customer.postcode
lay_address.country  := gtq_customer.country
print (lay_address)  // prints the lay_address Layout


Example syntax 2:
lay_error.text := ‘Error in Report’
print (lay_error, 1, prout_error)


### Header
The command ‘header’ sets a routine, or layout, to be executed when a new page of the report is started.


Figure 16-8: HEADER command

Example syntax:
header (lay_heading)

If a routine is specified, then the routine must be declared with a printer output parameter of the type ‘printer’, and the output id specified.
Example syntax:
routine main
begin_routine
header (rou_heading, prout)
main_report_code ()
end_routine

routine rou_heading (proutParameterIn: printer)
begin_routine
lay_heading.pageno := par_prout.linesprinted
print (lay_heading, proutParameterIn)
end_routine



The option ‘clear’ resets the earlier settings of the header.
Example syntax:
header (clear)


### Level break
The level break command can only be used within a loop; it’s purpose is to create automatic headers and footers upon change of a value in a field. This type of loop includes a table query or ‘readfile’ loop, (see section 18.1.6.1 Readfile).


Figure 16-9: Level break
The ‘test variable’ is used to trigger the execution of the print instructions or function. Upon a change of the value in the test variable, the footer, header and any functions defined are performed.
The parameter ‘footer’ specifies the layout or routine to print/perform as the footer, if the test variable changes.
Use of ‘footline’ is an optional parameter that specifies the line number that the footer layout must be printed, if the test variable changes.
The ‘header’ specifies the layout or routine to print/perform as the header, if the test variable changes.
‘headline’ is an optional parameter that specifies the line number that the header must be printed, if the test variable changes.
The ‘function’ defines a routine that should be performed if the test variable changes. ‘source’ specifies the variable on which the function is based, and the ‘variable’ specifies the variable where the result is placed.


Example syntax:
level_break(vn_cust_no, lay_foot, lay_head)
sum (vn-inv-amt, vn-inv-total)

### Skip


Figure 16-10: SKIP command

The ‘SKIP’ command allows for a specified number of lines in a text report to be skipped in the print output.
Example syntax:
skip (2)  // skip 2 lines


If specified with ‘top’, then the rest of the current page of output is skipped, and printing begins at the start on the first line of a new page.
Example syntax:
skip (top) // skip to new page

### Wait
The command ‘wait’ suspends the execution of a report for the number of seconds specified.

Figure 16-11: WAIT command

Example syntax:
wait (5)  //wait 5 seconds

When a report is in ‘wait’ state, it can be woken with the ‘wakeup’ command.

### Saverecoveryname

The ‘saverecoveryname’, (“srn”), command creates a save point during the running of a report.
This command:
- 67.1 Performs a database commit
- 67.2 Saves all files so far created by the report
- 67.3 Saves the srn variable structure that is declared in the options of the report
- 67.4 Saves all print outputs so far created by the report

If a report crashes, the AMT LION runtime environment automatically restarts it. If the subsequent restart crashes, AMT LION attempts to restart the report a maximum of five times.
In the restart process, the system variable ‘si-recover’ is set to ‘true’. The report then starts at the save point of the last database commit that was successful. The files, srn variable structure, and prints are also recovered.
Table query variables are not automatically restored. Any records from tables that are assumed to be currently available in memory, need to be explicitly re-read by the report.


Figure 16-12: SaveRecoveryName

The optional parameter ‘time’ specifies the number of seconds to suspend execution.
The option ‘nofreeoutput’, when added to the command, stops printed output being released. If not specified, any print output when the ‘srn’ command is executed, will be released to the printer.
Example syntax:
srn(,nofreeoutput)
### Commit
The ‘commit’ command is used to instruct the database engine to perform a physical update of all the logical updates that the report, so far, performed. After a commit, these updates cannot be undone, even if the report or the hardware of the physical server crashes. The updates are safe.
Example syntax:
commit ()  // make the logical update transactions safe

Reports that crash, and only written with a ‘commit’ instead of the  ‘saverecoveryname’ command (see section 16.7.6 Saverecoveryname), are not automatically restarted at runtime.

### Abort
The ‘Abort’ command in a report terminates the report immediately and rolls back any database transactions until the last ‘Commit’ or beginning of the report.
The ‘Abort’ in a report can be used in combination with the ‘SaveRecoveryName’. When the option ‘SAVERECOVERY’ is specified, the restart information is saved.

Figure 16-13: Abort
A report that is terminated with an ‘Abort’ will not restart automatically. If that’s required, the option ‘RESTART’ must be provided, and be used in combination with ‘SaveRecoveryName’.

### Start report
The ‘startreport’ command can be used in forms as well as in reports to start a report.


Figure 16-14: StartReport

AMT Developer Studio allows for layouts to be created for each language, as with forms, so optionally the ‘language’ parameter can be specified when using this command.
Example syntax:
startreport ('INVOICES')


A parameter can optionally be sent to the report. The simplest way to pass data to a report at the start is to use the system item ‘si-param’.
Example Syntax:
si-param := today.ccyymmdd
startreport ('INVOICES', '', si-param)

The developer can then reference si-param directly in the report.


### Input

The ‘input’ command requests data from the operator of the report at runtime.


Figure 16-15: Input

The variable is set up to receive the input from the operator of the report.
Example syntax
va-file-name := input ('Please give a filename')
## Code Editor Report Advanced Function
### Report personal options
Pressing the function key ‘F10’, and selecting the tab sheet ‘Reports’, shows the report’s personal options, (see Figure 16-16).


Figure 16-16: Report personal options

The only option here for text reports is the option to define the ‘Default page height’ of the print layout canvas.
The remaining options are all specific to graphical reporting.


Exercise 14: Create report



# Report Runtime
## Report Flow



Figure 17-1: Report transaction flow
## Running a report in the runtime environment
There are several ways to run a report in the runtime environment.

### Start report tab sheet
In AMT Screens, if the System Administrator grants suitable access rights in the AMT Control Center, the ‘Start Report’ tab sheet is visible. Clicking this tab sheet presents the ‘Start Report’ view, (see Figure 17-2).


Figure 17-2: Start report in AMT Screens

Queued Reports
‘Queued Reports’ displays report requests that are queued to be run.

Running Reports
‘Running Reports’ displays reports that are currently running.


Available Reports
‘Available Reports’ allows for the entry of the report name to be run, or for the report to be selected from the ‘Available Reports’ list. This list is controlled in the AMT Control Center.

Printer
The ‘Printer’ combo box allows for the entry, or the selection from the combo box, of the printer id.

Queue
‘Queue’ allows for the ‘Queue’ to be specified, where the report request is processed.

Request File
The ‘Request File’ allows for a file name to be specified, where expected answers to report messages are specified.

Backup folder
This is the directory where the backup of the report print file is placed. This overwrites the directory specified by the System Administrator in the AMT Control Center.

Report Parameter
The ‘Report parameter’ allows for a parameter to be passed to the variable/structure specified in the ‘Parameter Name’ of the options of a report, (see section 12.1.1 Options).

Global Parameter
‘Global parameter’ allows for a parameter to be passed to the system item ‘si-param’.


Do not Print
If this option is checked, then only a report file will be created, and no actual output will be printed.

Debug Version
A debug version of a report can only run when the setting in the AMT Control Center is ‘Development version’. When this is set, an extra option ‘Debug Version’ on the ‘Start Report’ tab sheet is available, (see Figure 17-2).
If this option is checked, then a debug version of the report is queued for the LionDebugger. The report can be debugged by using the LionDebugger as discussed in section 10 AMT LION Debugger section. The advantage of starting a debug version of the report in this way is the ease of passing parameters to the report.

Recover from Crashpoint
If a report crashes, then this option can be checked to run the report from the point where the crash occurred.

Run Report
Once the report is selected, and the options specified, then clicking this button creates a run report request.

### Start report in the AMT Control Center
Reports can be started within the AMT Control Center. Normally the AMT Control Center is for System Administrators only, but in a development environment it may also be used to start and manage reports.


Figure 17-3: AMT Control Center report management

More information on the use of the AMT Control Center is covered in the AMT Control Center Operations training which is a prerequisite for this training.

### Running a report from a sleeping / ever running report
A procedure can also be setup to start a report from a constantly active report, known as a ‘sleeping report’.
To do this, generally a table is created where all requests for reports are stored. The ‘sleeping report’ then reads this table and starts the reports by means of the ‘start’ or ‘startreport’ command, (see section 16.7.9 Start report).
‘Sleeping reports’ are intended to become active as soon as the application is 'up and running', and to stop when the application is terminating. The two global performable routines with the reserved names ‘startup’ and ‘closedown’ are perfect for this scenario, (see section 13.1.6 Startup and Closedown).
## Report management
Once a report runs, the output can be accessed through the ‘Report management’ view. This view also allows for the management of all reports, and their output.
Report management can be accessed in the runtime environment, if the system administrator has granted suitable access rights in the AMT Control Center, by clicking the tab sheet ‘Report management’, (see Figure 17-4).
Alternatively, ‘Report management’ can be accessed within the AMT Control Center, by clicking the menu item ‘Jobs’ and then ‘Job management’.


Figure 17-4: Report management in AMT Screens

The ‘Queued reports’ and ‘Running reports’ are displayed in the top left of the ‘Report management’ view. The ‘Delete’ button allows for any queued reports to be removed from the queue.
‘Completed reports’ are listed in the middle of the ‘Report management’ view, with the text reports being indicated by a notepad icon. Details in managing these completed reports can be found in section 17.3.1 Managing completed reports.

The ‘Completed reports’ list can be refined from the options in the top right of the ‘Report management’ view.
The following choices can be made to refine the list:
- 71.1 Date selections for those completed during a specified period
- 71.2 Reports run ‘Only today’
- 71.3 Reports ‘Printed today’
- 71.4 Reports ‘Not printed’
- 71.5 Just the current user’s, using the ‘My reports only’ checkbox
- 71.6 Specific reports by name
- 71.7 Another user’s reports by entry of their usercode
- 71.8 Reports sent to a specific printer

Any ‘Failed reports’ are displayed at the bottom of the ‘Report management’ view, (see Figure 17-4). These failed report entries can be removed by selecting one or more entries. Once the required failed report entries are selected, click the ‘Delete’ button.

### Managing completed reports
Several buttons at the side of the ‘Completed reports’ list allow for the management of the completed reports list, and of the report output, (see Figure 17-4).
When clicking the ‘Refresh’ button the list refreshes so that any newly completed reports are displayed.

Selecting the required report from the ‘Completed reports’ list and clicking the ‘Preview’ button opens a separate window in the Amt Control Center with the report output displayed, assuming that the report produced output, (see Figure 17-5). This can also be achieved by double-clicking on the required report in the ‘Completed reports’ list.


Figure 17-5: Example report output
Once the report output is displayed, buttons at the bottom of the window, allow for the printing of the report output, or performing a find within the report output. Clicking the ‘Close’ button closes the report output and returns focus to the ‘Report management’ view.
Selecting the report output and clicking the ‘View as doc’ button, (see Figure 17-4), opens the report output in Microsoft Word.
Selecting the report output and clicking the ‘Save as’ button opens up a dialog box to save the output as a text file.
The report output(s) can be deleted from the ‘Completed reports’ list by selecting the report output(s) and clicking the ‘Delete’ button.

## Debugging a report

A report can be debugged in a similar way as described in section 10 AMT LION Debugger. Instead of starting the user interface, a report can be started as shown in Figure 17-6.


Figure 17-6: Start report in Debugger

When the ‘Start Report’ button is clicked, a dialog box appears showing all reports that are generated for debug. See Figure 17-7.


Figure 17-7: Reports generated for ‘debug’

The tab sheet ‘Report request waiting for debugger’ shows all the reports that are started from the online as described in section 17.2.1 Start report tab sheet.
The tab sheet ‘Debug reports’ shows all reports that are generated for debug.
A debug session can be started by selecting the required report and press the ‘Debug’ button.

The code is loaded in the debugger. Execution stops at the automatically inserted breakpoint at the first statement of the main routine, (see Figure 17-8).


Figure 17-8: Debugger for a report

A report can be debugged in exactly the same way as a form.


Exercise 15: Run a report

# Files and AMT LION Applications

## File handling
File Handling can be performed in either a report or a form, but think carefully about building file handling in forms, as the performance of the screen can be affected, (e.g. read or writing thousands of records in a form transaction from/to a file). In this scenario, best practice is to store the file’s contents as a table in the database.
In AMT LION three kinds of files can be used, sequential files, relative I/O files (without an index), and indexed files. The different methods for file handling should not be intermixed in a report/form.
Sequential files are the recommended method for file handling. It is the standard and most efficient way of reading and writing files. The relative I/O and indexed file types are mainly present in AMT LION for compatibility with applications written originally in COBOL.



### Files Id’s
For a report, or a form, to be able to handle files, a file id must first be created. To create a file id, select ‘Files’, then ‘Id’s’ from the navigation tree of the object, and then click on the option ‘Add new file id’. A dialog box is then presented for the file id to be entered, (see Figure 18-1).


Figure 18-1: Add a file id


After entering a file id, and clicking the ‘OK’ button, the file id is then added to the navigation tree and the options of the file id are presented, as seen in Figure 18-2.


Figure 18-2: File id options
For files that are used by the report/form, the name of the file is entered in the ‘Physical Filename’ field; it is not necessary to enter the director. By default, the report/form uses the file located, with the given name, in the directory structure that is defined by the System Administrator in the AMT Control Center. If required, a full directory path and filename can be specified. This then overrides the default directory specified in the AMT Control Center.
If a file is created by a report/form then it is not necessary to specify a filename, unless the file needs to be kept after the completion of the report, or form transaction. If the ‘Physical Filename’ fieldname is left empty, and the file is not named at runtime, (see section 18.1.6.4 Namefile), then the file created during the run of a report, or a form transaction, is automatically removed on completion of the report, or form transaction.
When the file’s content needs to be presented in Unicode, the checkbox ‘Unicode file’ must be checked.
When the file’s record ending character differs from the application default, the character(s) can be set here. For normal Windows files, this is ‘CR/LF’ (Carriage Return/Line Feed). Optionally, this can be set to a single ‘CR’ or ‘LF’. It’s also possible to select no record ending character. In that case, the records are read based on the record length. Settings other than ‘CR/LF’ are typically used when the file is sent or received from an external source.
The ‘Recoverable’ checkbox can be checked when the report is designed as a critical report by the use of the ‘SRN’ command, (see 16.7.6 Saverecoveryname).

### Files Layouts
After creating a file id, (see section 18.1.1 Files Id’s), the Layouts of the file must be defined. To create a file layout, click the ‘Layouts’ option and the ‘Add new file layout’.
A dialog box then appears for the file layout name to be given, (see Figure 18-3). Using the ‘Add new file/table layout’ option, a complete table structure can be configured. Fields cannot be added or removed with this option. This option can be useful when complete records of a table need to be saved in a file.
For all other purposes, click the ‘Add new file layout’ option.



Figure 18-3: Add record layout


After entering a file layout name and clicking the ‘OK’ button, the file layout is added to the navigation tree and the file layout area displayed for the definition of the fields of the file layout, as can be seen in Figure 18-4 where ‘REC_Customer’ is added as a layout.


Figure 18-4: Record layout from table

File layout fields are created in the same way as table fields, (see section 0
Defining fields in a table), by using the ‘Insert’ or ‘Bulk Mode’ options from right-clicking in the layout area and using the popup menu, (see Figure 18-4).
A helpful option from the popup menu, ‘Import From Table’, (see Figure 18-4), allows for the fields to be selected from a table. Selecting this option opens a dialog box, where the table name can be selected from a drop down combo box.

After selecting the table, the fields of that table are automatically listed in the left of the screen, (see Figure 18-5).


Figure 18-5: Record layout from table dialog

Clicking the button , selects all the fields on the left and moves them to the right section in alphabetical order. The button , allows for a selected field to be moved to the right section. This allows for the record layout order to be specifically defined. The button  removes any selected fields from the right of the screen, (see Figure 18-6).
With the [Up] and [Down] arrow, fields can be moved up or down.


Figure 18-6: Record layout from table manage fields

Once the “Ok” button is clicked the file layout view is returned, (see Figure 18-7).


Figure 18-7: Record layout created
If required, the fields can still be reordered in ‘Bulk Mode’, by simply cutting and pasting the fields.
A file record layout created from a table does not retain a parent child relationship, (i.e. it is a one-time copy process, with no inheritance).
If the option ‘Import From Table’ is used to create a file record layout, then a routine is added in the code editor of the AMT Developer Studio automatically, (see Figure 18-8).


Figure 18-8: Code automatically added
This routine assigns values to the fields in the record layout from the buffer of a table query. The table query name still must be defined. The routine’s name can be modified as desired.

### Add fill/read file layout items
In the Code Wizard, the sixth option, ‘File layout items’, (see Figure 8-8) allows for the creation of code to read/fill all, or selected, fields of a record layout.
Selecting this option presents the view seen in Figure 18-9.


Figure 18-9: Record layout code wizard

Choosing the first option ‘Fill layout’, lists the layout items on the left ready for assignments, and the second option ‘Read layout’ lists the items on the right ready for assignment to other items/fields.

Once the required option is selected, click the ‘Next’ button. The fields of the file record layout are then presented for selection/de-selection (see Figure 18-10).


Figure 18-10: Record layout code wizard dialog

After selecting the records of the file record layout, click the ‘Finish’ button
This then adds the selected file record layouts to the code, so they are ready for assignment to/from other items. The option ‘Read layout’ was selected in the wizard to produce the code seen in Figure 18-11.


Figure 18-11: Code added by code wizard
### File indexes
For compatibility with applications originally written in COBOL, indexed files are available in AMT LION.
This method of handling files and storing data is strongly discouraged, and it is recommended that sequential files be used, if at all possible.
To create an index for a file, click on the ‘Indexes’ node of the navigation tree and click on ‘Add new file index’. This presents a dialog box for the file index name to be entered, (see Figure 18-12)


Figure 18-12: Add file index
Once the name is entered, and the ‘OK’ button clicked, the index is added to the navigation tree, and the view in Figure 18-13 is presented.


Figure 18-13: Add file index dialog

From the combo boxes the ‘File Id’ and the ‘Layout Id’ for the indexed file can be selected.
The ‘File Extension’ specifies the extension that is added to the indexed file’s name. The option ‘Unique index’ ensures the index file contains unique records.
The ‘Keys’ can be chosen from the drop down boxes, which are the keys to the index. Only one field may be chosen, but it is possible to select a field that is defined as a structure, which then contains many sub fields that act as the keys items.
In Figure 18-14, the definition of the indexed file is complete.


Figure 18-14: Add file index dialog completed

### Shared layouts
If multiple layouts are defined, it is possible in the definitions to add a subsection called ‘shared_layouts’.
Within this subsection, file layouts can be specified that together use the same piece of memory. A change of the value in one of the file layouts will also be reflected automatically in the layouts that are defined as shared.
Example syntax:
shared_layouts
tracking, tracking_new : shared

### Code commands for file handling
There are two methods within AMT LION for file handling. It is not possible to intermix these methods. Therefore, when using the following commands ‘readfile’ and ‘writefile’, it is not possible to use the file functions, ‘addrec’, ‘deleterec’, ‘locate’, ‘updaterec’, or ‘read’, (see section 18.1.7 File functions and properties).
#### Readfile
To use the ‘readfile’ command the records in the file must all be of the same length.
The command ‘readfile’ creates a loop to read records sequentially from a file. The ‘readfile’ must be ended with ‘endread’.



Figure 18-15: ReadFile

When using the ‘readfile’ command the ‘file id’ and the ‘file layout(s)’ name(s) must also be specified. One or more file layout names can be specified.
Optionally the ‘start record number’ can be specified. When set the file is read from the record after this record number (be aware that the first record in a file is numbered 0).
When using the readfile command to read the file, it is not possible to use the file functions, ‘addrec’, ‘deleterec’, ‘locate’, ‘updaterec’, or ‘read’, (see section 18.1.7 File functions and properties).
Example syntax
readfile (tracking, rec_tracking)
process_file_rec ()
endread


#### Writefile
The command ‘writefile’ creates a record in a file. Following the first ‘writefile’ that is executed at runtime the file then physically exists on the disk.



Figure 18-16: WriteFile

The file id and file layout are required when using this command.
Multiple record layouts can be used to write records to the same physical file, enabling header, detail and footer record layouts to be defined.
Example syntax:
writefile (file_cust, rec_cust)
      writefile (file_cust, rec_custfoot)

#### Sort
The ‘sort’ command is used to change the order of records in a file.


Figure 18-17: Sort

The ‘sort’ command must be specified with the ‘file id’, and the ‘file layout’ name. The field list to sort on must also be specified. One or more fields can be specified, each separated with a comma.
By default, the fields are sorted ascending. If a field needs to be sorted descending, then it must be prefixed with ‘dsc’.
Example syntax:
sort (tracking, rec_tracking, track_date, dsc track_time)



#### Namefile
The ‘namefile’ command allows for the assigning of a physical filename to a logical file id at runtime. This ensures that the file is kept on the disk after the completion of the report, or a form’s transaction. If no physical filename is entered, (see section 18.1.1 Files Id’s) and the file is not named at runtime, then the file created during the run of a report, or a form transaction, is automatically removed from the disk on completion of the report, or form transaction.



Figure 18-18: NameFile

The ‘file id’ and ‘file name’ are required values. If the ‘file name’ is not specified with a path, then the path defaults to the path specified in the AMT Control Center by the System Administrator.
The command ‘removefile’ can optionally be added. If the file does not exist and the ‘removefile’ is not specified, the report/transaction will wait for the file to be present on the first attempt to access the file.
If ‘removefile’ is added, then any existing file of that name is first removed.
Example syntax:
namefile (status, 'status' & today.ccyymmdd & '.dat')

#### Removefile
The command ‘removefile’ also exists in its own right, and as seen in section 18.1.6.4 Namefile), removes the file from the disk.
Example syntax:
removefile (status)


### File functions and properties
A number of file functions and properties exist that are included in the code completion popup menu of the file, (see Figure 18-19).



Figure 18-19: Autocompletion for file functions

The following file functions and properties are the most commonly used. A number of these functions are intended specifically for use with indexed or relative IO files, see section 18.1 File handling.


#### Create
The function ‘create’ creates an empty file. Any existing file, with the same path/name, is destroyed.
Example syntax:
cust_maillist.createfile (exclusive) resultokto sb_created

The use of ‘exclusive’ is optional. When ‘exclusive’ is used, then the created file cannot be simultaneously used in other processes. This improves the file handling performance as it eliminates continually opening and closing the file.
If ‘resultokto’ is defined and the create fails, ‘resok’ will be set to false and is passed back within the local defined Boolean (sb_created).
#### Open
The function ‘open’ opens a specified file for subsequent reading.
Example syntax:
cust_maillist.open (nowait)

The ‘nowait’ is optional, and ensures that the form transaction or report does not wait for the file to be present if it currently does not exist.
The file can also be opened exclusively, which is the same behavior, as seen in section 18.1.7.1 Create, when creating a file.
#### Read
The function ‘read’ reads one record from the file and places it into the record layout specified. Any subsequent ‘read’ reads are to retrieve the next record. This function cannot be used in conjunction with the ‘readfile’ or ‘writefile’ commands, (see section 18.1.6 Code commands for file handling).
Example syntax:
loop
cust_maillist.read (rec_cust_maillist)
process_rec ()
if cust_maillist.eof
bk
endif
endloop

In the example syntax, the record layout to use when reading the file is required, (e.g. ‘rec_cust_maillist’).
#### Eof
The boolean property ‘eof’ indicates if the end of the file is reached. The value changes from ‘false’ to ‘true’, as the last record of the file is read.
Example syntax:
if cust_maillist.eof
bk
endif
#### Addrec
The function ‘addrec’, adds one record to an indexed or relative IO file. This function cannot be used in conjunction with the ‘readfile’ or ‘writefile’ commands, (see section 18.1.6 Code commands for file handling).
The record layout must be specified, (e.g. ‘rec_cust_maillist’).
Example syntax:
cust_maillist.addrec (rec_cust_maillist)
#### Updaterec
The function ‘updaterec’, updates the current record in an indexed or relative IO file. This function cannot be used in conjunction with the ‘readfile’ or ‘writefile’ commands, (see section 18.1.6 Code commands for file handling).
The record layout must be specified, (e.g. ‘rec_cust_maillist’).
Example syntax:
cust_maillist.updaterec (rec_cust_maillist)
#### Append
The function ‘append’ opens an existing file for the subsequent addition of records during future writes. If the file does not exist then an empty file is created.
Example syntax:
cust_maillist.append ()
#### Deleterec
The function ‘deleterec’ removes the current record from an indexed or relative IO file. This function cannot be used in conjunction with the ‘readfile’ or ‘writefile’ commands, (see section 18.1.6 Code commands for file handling).
Example syntax:
cust_maillist.deleterec ()

The record is not removed physically from the file, but is set to ‘high values’, which ensures the record is not returned in an indexed file.

#### Close
The function ‘close’ closes the file and releases the lock on the file. A number of additional options can also be specified between the brackets, (i.e. ‘save’, ‘delete’, ‘rename’, and ‘lock’). If left blank, as in the example below, then the default ‘save’ option is used.
Example syntax:
cust_maillist.close ()




#### Copyfile
The function ‘copyfile’ copies the file contents to the specified destination.
Example syntax:
cust_maillist.copyfile (‘c:\backup\files’)
#### Deletefile
The function ‘deletefile’ deletes the file from disk.
Example syntax:
cust_maillist.deletefile ()
#### Exists
The boolean property ‘exists’ indicates whether the file actually exists.
Example syntax:
if cust_maillist.exists
process_file()
endif
#### Createddate and createdtime
The read only properties ‘createddate’ and ‘createdtime’ return the file creation date in ‘ccyymmdd’ format, and the file creation time in ‘hhmmss’ format accordingly.
Example syntax:
vn-file-date := cust_maillist.createddate
vn-file-time := cust_maillist.createdtime
#### Currentrecno
The property ‘currentrecno’ is an integer indicating the record pointers position in the file.
Example syntax:
vn-last-rec-read := cust_maillist.currentrecno

#### Lock records / unlock records
Files can be shared by simultaneously running reports and scripts. Locking is handled by the AMT File Controller.
Example syntax:
loop
cust_maillist.read (rec_cust_maillist)
vn-last-rec-read := cust_maillist.currentrecno
cust_maillist.lockrec(vn-last-rec-read)
process_rec ()
cust_maillist.unlock(vn-last-rec-read)
if cust_maillist.eof
bk
endif
endloop

### Global file definitions
Files that are used by multiple reports, forms or global routines, are best defined as an object in the ‘File Definitions’. This allows for any changes in the file to be maintained in one area, rather than having to change every object that uses the file.
#### Creating a global file definition
To create a global file definition, right-click on the folder ‘File Definitions’, in the repository view and select ‘Insert Object’, ‘Insert File Definition’, (see Figure 18-20).


Figure 18-20: Add file definition
A dialog box then appears to add the name and description of the file definition, (see Figure 18-21)


Figure 18-21: Add file definition dialog

After entering the name and description of the file the Options are displayed, (see Figure 18-22).


Figure 18-22: File definition options
Creating file ‘Id’s’ ‘Layouts’ and ‘Indexes’ is exactly the same as when created in a report, form, or global routine (see section 18.1.1 Files Id’s). Once the file ‘Id’ and ‘Layout’ are created, and if a relative IO or index file, the index, the global file definition can then be used in forms, reports and global routines.

#### Using a global file definition
Global file definitions can be used by reports, forms or global routines. Click  ‘Global Files’ (in the object), and click ‘Add file definition’. A dialog box allows selection of the global definition, (see Figure 18-23).


Figure 18-23: Use global file definition

After selecting the global file definition from the drop down combo box, the file id, the record lay-out, and index, (if a relative IO or index file), are created in the object, with the global file definition name shown in brackets, (see Figure 18-24).


Figure 18-24: Global file definition added
Exercise 16: Use file functions in a report

# Advanced Code Management

## Templates in the AMT LION Developer
Creating templates in your application helps to build a consistent application. Templates are used as a basis for creating application forms or reports.
A template is created in exactly the same way as application forms/reports, except that the right-click is on the ‘Templates’ folder.
A template is built in exactly the same way as application forms/reports.
After completion, a template must be validated, saved and checked-in before it can be used.
Now during the creation of a new application form, or report, the template can be chosen from the ‘Copy From’ template list, (see Figure 19-1).



Figure 19-1: Add report template dialog

Creating a form, or report, from a template does not create a relationship with the created object. It is a one-time process to copy the schema from the template.

Exercise 17: Create templates

## Exporting and importing
AMT Developer Studio offers the possibility to import and export applications, or parts of applications. This makes it easy to transport applications or objects between different AMT Developer Studio repositories/applications.
AMT Developer Studio exports the objects to a file with an extension ‘.lionsource’. This format is in a special layout format for AMT LION Developer. It is possible to export the source as a readable plain ASCII text file, but this file cannot be imported into AMT Developer Studio.

### Exporting
The option to export an application, or part of it, can be found in the ‘File’ menu, (see Figure 19-2).


Figure 19-2: Export

Once the ‘Export’ option is selected, the ‘Export source code’ dialog box is presented, (see Figure 19-3).


Figure 19-3: Export, select types

The export can be for the ‘Complete Repository’, (i.e. all applications), the ‘Complete Application (All revisions)’, the ‘Application version in generation set’ or ‘All revisions for the selected objects’ selected from the combo list box.
Checking the option ‘Application Options’, exports the system options object with any export executed.

Clicking one of the ‘Select’  buttons opens the view seen in Figure 19-4, which allows for the selection of particular objects to export.

Figure 19-4: Export, select objects
Once the object(s) are selected by checking the required objects, and the ‘Ok’ button pressed, (see Figure 19-4), the view returns to the ‘Export Source Code’ dialog, with the radio button indicating which object types are selected, (see Figure 19-5).


Figure 19-5: Export, objects selected
Clicking the ‘Start’ button opens a dialog to specify the directory and file name for the exported source. Once this is specified, the export begins, and progress of the export is displayed (see Figure 19-6).


Figure 19-6: Export logging





### Importing
The option to ‘Import’ is located in the ‘File’ menu, (see Figure 19-2). Once the ‘Import’ option is selected, the ‘Import LION Source’ dialog appears, (see Figure 19-7).


Figure 19-7: Import

The ‘Filename’ fieldname specifies the lionsource file to be imported. Once this file is specified, the ‘Load under application name’ is automatically filled with the application name of the AMT LION source contained in that import file.
This field can be overwritten to load the application under a different name, but the application name entered must exist.  If the lionsource is to be imported into a new specification then the application record must be created before attempting to import the source, (see section 2 Creating a New Application).
An option also exists to ‘Load shortcuts and create folders’ and to ‘skip duplicate objects, which both perform as expected.
When loading a partial application there may be a conflict between release labels in the file and those that already exist in the repository.  Select the appropriate radio button from the list provided in case this conflict exists.

Once the file is specified and the ‘Next’ button clicked, (see Figure 19-7), the view changes to that seen in Figure 19-8.


Figure 19-8: Import object list
The ‘Load as Version’ column shows the revision number that this object will be loaded as into the application. The ‘Load As Version’ revision number can be changed by clicking the ‘Load as Version’ button, which recalls the ‘Revision Comment’ dialog box, (see Figure 7-14).
By selecting an object from the list and clicking the button ‘Don’t Load selected’, the ‘Load As Version’ column changes to “*SKIP*, so that this object is not loaded, (see Figure 19-10).
Object that are locked, cannot be loaded and will be skipped automatically. A warning message will be shown.


Figure 19-9: Locked objects


Once the import can start, click the ‘Finish’ button to start the import. This presents a dialog, similar to that seen in Figure 19-6, showing the progress of the import.


Figure 19-10: Skip objects

Exercise 18: Export sources


# Script Management
## Setting Up Scripts
Please note, before scripts can be managed and edited from within the AMT Developer Studio the 'Script Source folder' in the Generation Set must be set to the folder that will contain the scripts for this application.
Figure 20-1: Skip objects

Scripts managed and edited within the AMT Developer Studio are stored both in the AMT Repository and on disk in the subfolders of the folder set in the Generation Set.

In the Enterprise Repository of the AMT Developer Studio, the node ‘Scripting’ contains four folders as can be seen in the image below. If required, more folders can be added by right-clicking on the Scripting node and selecting Insert Object > Script Folder.
Figure 20-2: Script Folder

Folders (apart from the Templates folder) can also be removed by right-clicking the folder and selecting the option 'Delete Script Folder'. Remove only works when the folder is empty, otherwise a warning is shown.
The ‘Templates’ folder is a special folder. Template scripts created in this folder cannot be executed. Therefore, they are not stored on disk but only in the Enterprise Repository. These templates can then be used as a starting point for creating executable scripts in the other folders. The Templates folder can never be removed from the Scripting node.

The Scripting node comes with the standard folders Libraries, Scripts, Settings and Templates. Asysco recommends these folders with the following usage:


Right-clicking The ‘Libraries’, ‘Scripts’, or ‘Settings’ folder displays a context menu with several options. The ‘Templates’ folder only let the end-user add a new template through the offered action 'Insert Object > Script file'.

• Options
If Options is selected, the following options can be set: the name of the folder, an optional description for the folder and the relative path of this folder. This path is relative to the Script Source folder set in the Generation Set of the application) Insert Object: Insert Object will let the end-user choose between inserting a new Script Folder or a Script File.

• Insert Object
Allows the end-user to choose between inserting a new Script Folder or a Script File.


• Insert Script Folder
When 'Insert Script Folder' is selected a new script folder is created. This folder will be a sub folder of the currently selected Script Folder. The options menu of this new Script Folder open in which the Name of the Script Folder and the Description can be set. The relative path is fixed and set as child folder to the selected Script Folder.








Figure 20-3: Skip objects

• Insert Script File
- 76.1 ‘Insert Script File' creates a new script file both in the Repository and as a file in the currently selected script folder on disk.

Figure 20-4: Skip objects

The dialog allows for entry of a Script file name and description. The developer can also select and ‘Copy from’ a Template if template scripts are created in the ‘Template’ folder. The ‘Type’ selector is set to the type Script File (fixed), with the exception of the ‘Template’ folder (where it is set to the type: Template).

• Add Missing Script Files
If script files are added to the currently selected Script Folder outside of the AMT Developer Studio, these new script files can be added to the Repository database using this option.

• Open Script Folder in explorer
Selecting this action open a Windows File Explorer window displaying the currently selected script folder on disk.

• Delete Script Folder
If the currently selected script folder is empty this action deletes the folder, otherwise an error popup is displayed.

• Script File Options
- Name: The name of the script file excluding the extension. Note that the script file object name in the repository includes the extension, so that it can be used in 'Open Commands' for example
- Description: Allows the developer to enter a short description of the folder’s purpose
Please note that AMT Developer Studio does not perform syntax checking, code completion or debugging options for scripts that are managed within the program. When Script files are managed in the AMT Developer Studio, it is possible to do version management using the revisions screen.
For more information on scripts in the AMT Developer Studio, visit the online help manual or watch this video.


Exercise 19: Scripting

- 76.2 Create a new script folder
- 76.3 Add a simple script into the folder






















# Appendix A: AMT Developer Studio Keyboard Shortcuts




# Appendix A: AMT Debugger Keyboard Shortcuts



# Information and feedback
General information about Asysco and the AMT product suite can be found on the website: www.asysco.com.
For feedback on documentation issues contact Asysco through the email address, documentation@asysco.com.
For general feedback contact Asysco through the email address lionsupport@asysco.com.
