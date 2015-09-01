VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   BackColor       =   &H0000C000&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   9480
   ClientLeft      =   150
   ClientTop       =   435
   ClientWidth     =   9450
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9480
   ScaleWidth      =   9450
   StartUpPosition =   3  'Windows Default
   WhatsThisHelp   =   -1  'True
   Begin VB.CommandButton Command4 
      Caption         =   "Vymaž históriu"
      Height          =   615
      Left            =   3240
      TabIndex        =   48
      Top             =   6600
      Width           =   615
   End
   Begin VB.Timer Timer7 
      Enabled         =   0   'False
      Interval        =   10000
      Left            =   3960
      Top             =   6600
   End
   Begin VB.Timer Timer6 
      Enabled         =   0   'False
      Interval        =   3000
      Left            =   3960
      Top             =   6120
   End
   Begin VB.Timer Timer5 
      Enabled         =   0   'False
      Interval        =   8000
      Left            =   3960
      Top             =   5640
   End
   Begin MSComDlg.CommonDialog CD1 
      Left            =   3960
      Top             =   5040
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton Command8 
      Caption         =   "WR"
      Height          =   615
      Left            =   3240
      Style           =   1  'Graphical
      TabIndex        =   47
      ToolTipText     =   "Zapíše parametre zo súboru do dosky"
      Top             =   5040
      Width           =   615
   End
   Begin VB.CommandButton Command7 
      Caption         =   "RD"
      Height          =   615
      Left            =   3240
      Style           =   1  'Graphical
      TabIndex        =   46
      ToolTipText     =   "Naèíta parametre z dosky do súboru"
      Top             =   4320
      Width           =   615
   End
   Begin VB.Timer Timer4 
      Enabled         =   0   'False
      Interval        =   500
      Left            =   3960
      Top             =   3960
   End
   Begin VB.CommandButton Command6 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Reset + Autorizovaný prístup"
      Height          =   375
      Left            =   1320
      TabIndex        =   45
      Top             =   8760
      Width           =   2535
   End
   Begin VB.Timer Timer3 
      Enabled         =   0   'False
      Interval        =   300
      Left            =   3960
      Top             =   3480
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H80000008&
      Height          =   5655
      Index           =   0
      Left            =   2640
      ScaleHeight     =   375
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   31
      TabIndex        =   44
      TabStop         =   0   'False
      ToolTipText     =   "Kabínové vo¾by"
      Top             =   1560
      Width           =   495
   End
   Begin VB.PictureBox Picture2 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      FillStyle       =   0  'Solid
      ForeColor       =   &H80000008&
      Height          =   5655
      Left            =   960
      ScaleHeight     =   375
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   111
      TabIndex        =   43
      TabStop         =   0   'False
      ToolTipText     =   "Šachta"
      Top             =   1560
      Width           =   1695
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H80000008&
      Height          =   5655
      Index           =   1
      Left            =   480
      ScaleHeight     =   375
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   31
      TabIndex        =   42
      TabStop         =   0   'False
      ToolTipText     =   "Vo¾by dole"
      Top             =   1560
      Width           =   495
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H80000008&
      Height          =   5655
      Index           =   2
      Left            =   0
      ScaleHeight     =   375
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   31
      TabIndex        =   41
      TabStop         =   0   'False
      ToolTipText     =   "Vo¾by hore"
      Top             =   1560
      Width           =   495
   End
   Begin VB.Timer Timer2 
      Enabled         =   0   'False
      Interval        =   3000
      Left            =   3960
      Top             =   3000
   End
   Begin VB.CommandButton Command2 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Nové dáta"
      Height          =   615
      Left            =   0
      TabIndex        =   40
      Top             =   840
      Width           =   975
   End
   Begin VB.CommandButton Command1 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Reset"
      Height          =   375
      Left            =   0
      TabIndex        =   39
      Top             =   8760
      Width           =   1215
   End
   Begin VB.PictureBox Picture5 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   1080
      ScaleHeight     =   39
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   95
      TabIndex        =   38
      TabStop         =   0   'False
      ToolTipText     =   "Smer jazdy"
      Top             =   840
      Width           =   1455
   End
   Begin VB.CommandButton Command3 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Enter"
      Height          =   615
      Index           =   4
      Left            =   3240
      Style           =   1  'Graphical
      TabIndex        =   37
      Top             =   2640
      Width           =   615
   End
   Begin VB.CommandButton Command3 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Dole"
      Height          =   615
      Index           =   3
      Left            =   3240
      Style           =   1  'Graphical
      TabIndex        =   36
      Top             =   2040
      Width           =   615
   End
   Begin VB.CommandButton Command3 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Hore"
      Height          =   615
      Index           =   2
      Left            =   3240
      Style           =   1  'Graphical
      TabIndex        =   35
      Top             =   1440
      Width           =   615
   End
   Begin VB.CommandButton Command3 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Plus"
      Height          =   615
      Index           =   1
      Left            =   3240
      Style           =   1  'Graphical
      TabIndex        =   34
      Top             =   840
      Width           =   615
   End
   Begin VB.CommandButton Command3 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Mínus Esc"
      Height          =   615
      Index           =   0
      Left            =   2640
      Style           =   1  'Graphical
      TabIndex        =   33
      Top             =   840
      Width           =   615
   End
   Begin VB.ListBox List1 
      Appearance      =   0  'Flat
      Height          =   1395
      Left            =   0
      TabIndex        =   0
      TabStop         =   0   'False
      ToolTipText     =   "História chýb"
      Top             =   7320
      Width           =   3855
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   200
      Left            =   3960
      Top             =   2520
   End
   Begin MSCommLib.MSComm MSComm1 
      Left            =   3960
      Top             =   4440
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      CommPort        =   2
      DTREnable       =   -1  'True
      RTSEnable       =   -1  'True
      InputMode       =   1
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   25
      Left            =   2160
      TabIndex        =   26
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   9
      Left            =   2160
      TabIndex        =   10
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   31
      Left            =   3600
      TabIndex        =   32
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   30
      Left            =   3360
      TabIndex        =   31
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   29
      Left            =   3120
      TabIndex        =   30
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   28
      Left            =   2880
      TabIndex        =   29
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   27
      Left            =   2640
      TabIndex        =   28
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   26
      Left            =   2400
      TabIndex        =   27
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   24
      Left            =   1920
      TabIndex        =   25
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   23
      Left            =   1680
      TabIndex        =   24
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   22
      Left            =   1440
      TabIndex        =   23
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   21
      Left            =   1200
      TabIndex        =   22
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   20
      Left            =   960
      TabIndex        =   21
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   19
      Left            =   720
      TabIndex        =   20
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   18
      Left            =   480
      TabIndex        =   19
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   17
      Left            =   240
      TabIndex        =   18
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   16
      Left            =   0
      TabIndex        =   17
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   15
      Left            =   3600
      TabIndex        =   16
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   14
      Left            =   3360
      TabIndex        =   15
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   13
      Left            =   3120
      TabIndex        =   14
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   12
      Left            =   2880
      TabIndex        =   13
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   11
      Left            =   2640
      TabIndex        =   12
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   10
      Left            =   2400
      TabIndex        =   11
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   8
      Left            =   1920
      TabIndex        =   9
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   7
      Left            =   1680
      TabIndex        =   8
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   6
      Left            =   1440
      TabIndex        =   7
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   5
      Left            =   1200
      TabIndex        =   6
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   4
      Left            =   960
      TabIndex        =   5
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   3
      Left            =   720
      TabIndex        =   4
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   2
      Left            =   480
      TabIndex        =   3
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   1
      Left            =   240
      TabIndex        =   2
      Top             =   0
      Width           =   255
   End
   Begin VB.Label Label0 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   15.75
         Charset         =   238
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   375
      Index           =   0
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   255
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Const no_of_floors = 32
Const in_msg_size = 5
Const spec_string = "0VA0----"
Const max_errors = 28

Private Type data_entry
    t As String
    l As String
    r As String
End Type

Private Type stack_entry
    id As String
    y1 As String
    y2 As String
End Type

Dim params(0 To 7 * 256 - 1) As Byte
Dim data(0 To 100) As data_entry
Dim data_no As Integer
Dim errors(0 To 50) As String
Dim error_no As Integer
Dim stack(0 To 50) As stack_entry
Dim stack_no As Integer
Dim floors(0 To 50) As String
Dim floor_no As Integer
Dim volby(0 To no_of_floors - 1, 0 To 2) As Boolean
Dim liftsub(0 To 20) As Single

Dim the_caption
Dim bitmask(0 To 7) As Byte
Dim rcvd As Integer

Dim d_h As Single
Dim d_w As Single
Dim d_cx As Single
Dim d_cy As Single
Dim d_cw As Single
Dim su_dvere_a As Boolean
Dim su_dvere_b As Boolean
Dim dax As Single
Dim dbx As Single
Dim dadx As Single
Dim dbdx As Single
Dim all_closed As Boolean

Dim lpos As Byte
Dim lsub As Byte
Dim smer As Byte
Dim oerror As Byte
Dim svetlo As Boolean

Dim in_message(0 To in_msg_size - 1) As Byte
Dim in_bytes() As Byte
Dim state As Integer
Dim entry_no As Integer
Dim entry_mul As Integer
Dim entry_len As Integer
Dim entry_ind As Integer
Dim entry_name As String
Dim entry_field(0 To 1000) As Byte
Dim pocitadlo As Integer
Dim esc As String
Dim got_error(1 To max_errors) As Byte
Dim old_error(1 To max_errors) As Byte

Private Sub send(s)
    'Debug.Print s '!!!!!!!
    buffer = s
    MSComm1.Output = buffer
End Sub

Private Function get_bit(data, n) As Boolean
    get_bit = ((data And bitmask(n)) <> 0)
End Function

Private Function hex2(w) As String
    q = LCase(Hex(w))
    If Len(q) < 2 Then q = "0" + q
    hex2 = q
End Function

Private Function hexn(n, w) As String
    q = LCase(Hex(w))
    Do While Len(q) < n
        q = "0" + q
    Loop
    hexn = q
End Function

Private Function get_this(t, l, r) As Boolean
    If data_no = 0 Then GoTo no_more_this
    For i = 0 To data_no - 1
        If data(i).t = t And data(i).l = l Then
            r = data(i).r
            data_no = data_no - 1
            data(i) = data(data_no)
            get_this = True
            Exit Function
        End If
    Next i
no_more_this:
    get_this = False
End Function

Private Function get_any(t, l, r)
    If data_no = 0 Then GoTo no_more_any
    For i = 0 To data_no - 1
        If data(i).t = t Then
            l = data(i).l
            r = data(i).r
            data_no = data_no - 1
            data(i) = data(data_no)
            get_any = True
            Exit Function
        End If
    Next i
no_more_any:
    get_any = False
End Function

Private Sub Command1_Click()
    h = MsgBox("Naozaj chcete resetnú rozvádzaè?", 1, the_caption)
    If h = 1 Then
        Call send("reset")
    End If
End Sub

Private Sub Command2_Click()
    Call send("debug on")
End Sub

Private Sub Command3_Click(Index As Integer)
    h = "msg0" + hex2(AscB("c")) + hex2(Index)
    Call send(h)
End Sub

Private Sub Command4_Click()
    On Error Resume Next
    Kill "history.txt"
    List1.Clear
    error_no = 0
End Sub

'Private Sub Command5_Click()
'    s = errors(Int(1 + 28 * Rnd()))
'    add_to_history (s)
'End Sub

Private Sub add_to_history(s)
    ss = CStr(Date) + " " + CStr(Time) + " " + s
    Open "history.txt" For Append As #3
    Print #3, ss
    Close #3
    List1.AddItem ss
End Sub

Private Sub Command6_Click()
    h = MsgBox("Naozaj chcete resetnú rozvádzaè a vojs do autorizovanej oblasti?", 1, the_caption)
    If h = 1 Then
        Call send("reset")
        Timer4.Enabled = True
        pocitadlo = 5
    End If
End Sub

Private Sub Command7_Click()
    'ChDir ("c:\windows\plocha\práca")   '!!!!!
    
    Call send("debug off")
    Timer1.Enabled = False
    Timer2.Enabled = False
    
    On Error Resume Next
    CD1.CancelError = True
    CD1.Filter = "All files (*.*)|*.*|Text files (*.txt)|*.txt"
    CD1.ShowSave
    If Err.Number = 0 Then
        Command7.Enabled = False
        Open CD1.FileName For Output As #1
        If MSComm1.InBufferCount > 0 Then in_bytes = MSComm1.Input
        Timer5.Enabled = True
        Call send("parameters")
        total = 0
        Do While Timer5.Enabled And total < 8 * 256
            DoEvents
            rcvd = MSComm1.InBufferCount
            If rcvd > 0 Then
                in_bytes = MSComm1.Input
                For j = LBound(in_bytes) To UBound(in_bytes)
                    Print #1, in_bytes(j)
                    total = total + 1
                Next j
            End If
        Loop
        If total = 8 * 256 Then
            Command7.BackColor = RGB(0, 255, 0)
        Else
            Command7.BackColor = RGB(255, 0, 0)
        End If
        Close #1
        Command7.Enabled = True
    End If
    Call send("debug on")
    Timer1.Enabled = True
    Timer2.Enabled = True
End Sub

Private Sub Command8_Click()
    'ChDir ("c:\windows\plocha\práca")   '!!!!!
    
    Call send("debug off")
    Timer1.Enabled = False
    Timer2.Enabled = False
    
    On Error Resume Next
    CD1.CancelError = True
    CD1.Filter = "All files (*.*)|*.*|Text files (*.txt)|*.txt"
    CD1.ShowOpen
    If Err.Number = 0 Then
        Command8.Enabled = False
        Call send(esc + esc + "download")
        Timer7.Enabled = True
        Open CD1.FileName For Input As #1
        Open "params.asm" For Output As #2
        Print #2, "cseg at 0"
        i = 0
        Do While Not EOF(1)
            Line Input #1, hlp
            params(i) = Val(hlp)
            Print #2, "db " + hlp
            i = i + 1
        Loop
        Close #1
        Close #2
        Call Shell("asem params.asm params.hex", vbHide)
        s = ""
        Do While Timer7.Enabled And InStr(s, "ready to download") = 0
            DoEvents
            If MSComm1.InBufferCount > 0 Then
                in_bytes = MSComm1.Input
                For i = LBound(in_bytes) To UBound(in_bytes)
                    s = s + Chr(in_bytes(i))
                Next i
            End If
        Loop
        If InStr(s, "ready to download") = 0 Then
            Command8.BackColor = RGB(255, 0, 0)
            Command8.ToolTipText = "Doska neodpoveda"
            Command8.Enabled = True
            GoTo done_wr
        End If
        
        Open "params.hex" For Input As #1
        Do While Not EOF(1)
            Line Input #1, hlp
            Call send(hlp)
        Loop
        Close #1
        Command8.BackColor = RGB(255, 255, 0)
        Timer6.Enabled = True
        Do While Timer6.Enabled
            DoEvents
        Loop
        in_bytes = MSComm1.Input
        
        ' check
        Timer5.Enabled = True
        Call send("parameters")
        total = 0
        same = True
        Do While Timer5.Enabled And total < 7 * 256 And same
            DoEvents
            rcvd = MSComm1.InBufferCount
            If rcvd > 0 Then
                in_bytes = MSComm1.Input
                For j = LBound(in_bytes) To UBound(in_bytes)
                    same = same And (in_bytes(j) = params(total))
                    total = total + 1
                Next j
            End If
        Loop
        If Timer5.Enabled And same Then
            Command8.BackColor = RGB(0, 255, 0)
            Command8.ToolTipText = "Uspech"
        Else
            Command8.BackColor = RGB(255, 0, 0)
            Command8.ToolTipText = "Zapisane a nacitane parametre sa lisia"
        End If
        Command8.Enabled = True
    End If
    
done_wr:
    Call send("debug on")
    Timer1.Enabled = True
    Timer2.Enabled = True
End Sub

Private Sub Form_Load()
    esc = Chr(27)
    'Open "c:\windows\plocha\práca\monitor4.txt" For Input As #1  '!!!!!!!!!!
    Open "monitor4.txt" For Input As #1
    t = ""
    data_no = 0
    Do While Not EOF(1)
        Line Input #1, s
        h = InStr(s, ";")
        If h > 0 Then s = Left(s, h - 1)
        s = Trim(s)
        l = InStr(s, "[")
        r = InStr(s, "]")
        If l > 0 And r > 0 And l < r Then
            t = Trim(Mid(s, l + 1, r - l - 1))
        Else
            h = InStr(s, "=")
            If h > 0 Then
                data(data_no).t = t
                data(data_no).l = Left(s, h - 1)
                data(data_no).r = Right(s, Len(s) - h)
                data_no = data_no + 1
            End If
        End If
    Loop
    Close #1
    If get_this("general", "caption", h) Then the_caption = h Else the_caption = "?"
    If get_this("port", "no", port_no) Then MSComm1.CommPort = port_no
    If get_this("port", "settings", port_set) Then MSComm1.Settings = port_set
    If get_this("doors", "a", h) Then su_dvere_a = CBool(h)
    If get_this("doors", "b", h) Then su_dvere_b = CBool(h)
    error_no = 0
    Do While get_any("errors", l, r)
        h = CInt(l)
        errors(h) = r
    Loop
    floor_no = 2
    Do While get_any("floors", l, r)
        h = CInt(l)
        floors(h) = r
    Loop
    Do While get_any("liftsub", l, r)
        h = CInt(l)
        liftsub(h) = CInt(r) / 100
    Loop
    Form1.Caption = the_caption + " na COM" + port_no + " (" + port_set + ")"
    Form1.Width = Form1.Width + Command6.Left + Command6.Width - Form1.ScaleWidth
    Form1.Height = Form1.Height + Command6.Top + Command6.Height - Form1.ScaleHeight
    d_w = Picture2.ScaleWidth
    d_h = Picture2.ScaleHeight
    d_cx = Int(0.07 * d_w)
    d_cw = Int(d_w - 2 * d_cx)
    h = 1
    For i = 0 To 7
        bitmask(i) = h
        h = h * 2
    Next i
    lpos = 0
    lsub = 0
    oerror = 0
    MSComm1.PortOpen = True
    MSComm1.InBufferCount = 0
    MSComm1.OutBufferCount = 0
    Call send("debug on")
    state = 0
    entry_no = 0
    Timer1.Enabled = True
    Timer2.Enabled = True
    Timer3.Enabled = True
    
    On Error GoTo krappy1
    Open "history.txt" For Input As #1
    Do While Not EOF(1)
        Line Input #1, s
        List1.AddItem s
    Loop
    Close #1
    GoTo krappy2
    
krappy1:
    Open "history.txt" For Output As #1
    Close #1
krappy2:

End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call send("debug off")
End Sub

Public Sub redraw_1()
    Picture1(0).Cls
    h = Picture1(0).ScaleHeight / floor_no
    w = Picture1(0).ScaleWidth
    For i = 0 To floor_no - 1
        tp = (floor_no - i - 1) * h
        bm = tp + h
        If volby(i, 0) Then Picture1(0).Line (0, tp)-(w, bm), QBColor(14), BF
        If i > 0 Then Picture1(0).Line (0, bm)-(w, bm), QBColor(0)
        s = floors(i)
        Picture1(0).CurrentX = 0.5 * (w - Picture1(0).TextWidth(s))
        Picture1(0).CurrentY = tp + 0.5 * (h - Picture1(0).TextHeight(s))
        Picture1(0).Print s
    Next i
End Sub

Public Sub redraw_2()
    Picture2.Cls
    h = d_h / floor_no
    If lsub < 20 Then hlp = lpos + liftsub(lsub)
    yy2 = d_h - hlp * h
    yy1 = yy2 - h
    Picture2.Line (0, yy1)-(d_cx, yy2), QBColor(0), BF
    Picture2.Line (d_w - d_cx, yy1)-(d_w, yy2), QBColor(0), BF
    d_cy = 0.5 * (yy1 + yy2 - d_cw)
    If d_cy < 0 Then d_cy = 0
    If d_cy > d_h - d_cw Then d_cy = d_h - d_cw
    xx = 0.5 * d_w
    Picture2.Line (xx, 0)-(xx, d_cy)
    Call draw_cabin
End Sub

Private Sub draw_cabin()
    If svetlo Then c = QBColor(7) Else c = QBColor(8)
    Picture2.FillColor = c
    Picture2.Line (d_cx, d_cy)-(d_cx + d_cw, d_cy + d_cw), QBColor(0), B
    If svetlo Then
        Picture2.DrawWidth = 3
        c = QBColor(14)
        t = 0.6
        xx1 = get_x(-t, 1, 1 - t)
        yy1 = get_y(-t, 1, 1 - t)
        xx2 = get_x(t, 1, 1 - t)
        xx3 = get_x(-t, 1, 1 + t)
        yy3 = get_y(-t, 1, 1 + t)
        xx4 = get_x(t, 1, 1 + t)
        dx1 = (xx2 - xx1) / 3
        dx2 = (xx4 - xx3) / 3
        For i = 1 To 4
            Picture2.Line (xx1, yy1)-(xx3, yy3), c
            xx1 = xx1 + dx1
            xx3 = xx3 + dx2
        Next i
        Picture2.DrawWidth = 1
    End If
    If su_dvere_a Then
        c = QBColor(15)
        t = 0.9 * dax
        xx1 = get_x(-1, 1, 1 - t)
        yy1 = get_y(-1, 1, 1 - t)
        yy2 = get_y(-1, -1, 1 - t)
        xx3 = get_x(-1, 1, 1 + t)
        yy3 = get_y(-1, 1, 1 + t)
        yy4 = get_y(-1, -1, 1 + t)
        If t = 0 Then
            Picture2.Line (xx1, yy1)-(xx1, yy2), QBColor(0)
        Else
            dy = (yy3 - yy1) / (xx3 - xx1)
            y1 = yy1: y2 = yy2
            For i = xx1 To xx3 Step 1
                Picture2.Line (i, y1)-(i, y2), c
                y1 = y1 + dy
                y2 = y2 - dy
            Next i
            Picture2.Line (xx1, yy1)-(xx1, yy2), QBColor(0)
            Picture2.Line (xx3, yy3)-(xx3, yy4), QBColor(0)
        End If
    End If
    If su_dvere_b Then
        c = QBColor(15)
        t = 0.9 * dbx
        xx1 = get_x(1, 1, 1 - t)
        yy1 = get_y(1, 1, 1 - t)
        yy2 = get_y(1, -1, 1 - t)
        xx3 = get_x(1, 1, 1 + t)
        yy3 = get_y(1, 1, 1 + t)
        yy4 = get_y(1, -1, 1 + t)
        If t = 0 Then
            Picture2.Line (xx1, yy1)-(xx1, yy2), QBColor(0)
        Else
            dy = (yy3 - yy1) / (xx1 - xx3)
            y1 = yy1: y2 = yy2
            For i = xx1 To xx3 Step -1
                Picture2.Line (i, y1)-(i, y2), c
                y1 = y1 + dy
                y2 = y2 - dy
            Next i
            Picture2.Line (xx1, yy1)-(xx1, yy2), QBColor(0)
            Picture2.Line (xx3, yy3)-(xx3, yy4), QBColor(0)
        End If
    End If
    xx1 = get_x(-1, 1, 2)
    yy1 = get_y(-1, 1, 2)
    xx2 = get_x(1, -1, 2)
    yy2 = get_y(1, -1, 2)
    Picture2.Line (d_cx, d_cy)-(d_cx + d_cw, d_cy + d_cw), QBColor(0)
    Picture2.Line (d_cx + d_cw, d_cy)-(d_cx, d_cy + d_cw), QBColor(0)
    Picture2.Line (xx1, yy1)-(xx2, yy2), QBColor(0), B
End Sub

Function get_x(x, y, z)
    get_x = d_cx + 0.5 * d_cw * (1 + x * 2 / (2 + z))
End Function
 
Function get_y(x, y, z)
    get_y = d_cy + 0.5 * d_cw * (1 - y * 2 / (2 + z))
End Function

Public Sub redraw_3()
    Picture1(1).Cls
    h = Picture1(1).ScaleHeight / floor_no
    w = Picture1(1).ScaleWidth
    If h < w Then m = h Else m = w
    m = 0.7 * m
    xx1 = 0.5 * (w - m)
    xx2 = 0.5 * (w + m)
    xx3 = 0.5 * w
    yy1 = 0.5 * h - 0.433 * m
    yy3 = 0.5 * h + 0.433 * m
    For i = 0 To floor_no - 1
        tp = (floor_no - i - 1) * h
        bm = tp + h
        If volby(i, 1) Then Picture1(1).Line (0, tp)-(w, bm), QBColor(14), BF
        If i > 0 Then Picture1(1).Line (0, bm)-(w, bm), QBColor(0)
        Picture1(1).Line (xx1, tp + yy1)-(xx2, tp + yy1), QBColor(0)
        Picture1(1).Line (xx2, tp + yy1)-(xx3, tp + yy3), QBColor(0)
        Picture1(1).Line (xx3, tp + yy3)-(xx1, tp + yy1), QBColor(0)
    Next i
End Sub

Public Sub redraw_4()
    Picture1(2).Cls
    h = Picture1(2).ScaleHeight / floor_no
    w = Picture1(2).ScaleWidth
    If h < w Then m = h Else m = w
    m = 0.7 * m
    xx1 = 0.5 * (w - m)
    xx2 = 0.5 * (w + m)
    xx3 = 0.5 * w
    yy1 = 0.5 * h + 0.433 * m
    yy3 = 0.5 * h - 0.433 * m
    For i = 0 To floor_no - 1
        tp = (floor_no - i - 1) * h
        bm = tp + h
        If volby(i, 2) Then Picture1(2).Line (0, tp)-(w, bm), QBColor(14), BF
        If i > 0 Then Picture1(2).Line (0, bm)-(w, bm), QBColor(0)
        Picture1(2).Line (xx1, tp + yy1)-(xx2, tp + yy1), QBColor(0)
        Picture1(2).Line (xx2, tp + yy1)-(xx3, tp + yy3), QBColor(0)
        Picture1(2).Line (xx3, tp + yy3)-(xx1, tp + yy1), QBColor(0)
    Next i
End Sub

Public Sub redraw_5()
    Picture5.Cls
    h = 0.5 * Picture5.ScaleHeight
    w = Picture5.ScaleWidth
    If h < w Then m = h Else m = w
    m = 0.7 * m
    xx1 = 0.5 * (w - m)
    xx2 = 0.5 * (w + m)
    xx3 = 0.5 * w
    yy1 = 0.5 * h - 0.433 * m
    yy3 = 0.5 * h + 0.433 * m
    tp = 0
    bm = h
    If (smer = 1) Or (smer = 3) Then Picture5.Line (0, tp)-(w, bm), QBColor(14), BF
    Picture5.Line (xx1, tp + yy3)-(xx2, tp + yy3), QBColor(0)
    Picture5.Line (xx2, tp + yy3)-(xx3, tp + yy1), QBColor(0)
    Picture5.Line (xx3, tp + yy1)-(xx1, tp + yy3), QBColor(0)
    tp = h
    bm = 2 * h
    If (smer = 2) Or (smer = 3) Then Picture5.Line (0, tp)-(w, bm), QBColor(14), BF
    Picture5.Line (xx1, tp + yy1)-(xx2, tp + yy1), QBColor(0)
    Picture5.Line (xx2, tp + yy1)-(xx3, tp + yy3), QBColor(0)
    Picture5.Line (xx3, tp + yy3)-(xx1, tp + yy1), QBColor(0)
End Sub

Private Sub Picture1_MouseDown(Index As Integer, Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 1 Then
        hlp = Int(floor_no * (Picture1(Index).ScaleHeight - y) / Picture1(Index).ScaleHeight)
        If hlp >= 0 And hlp < floor_no Then
            If volby(hlp, Index) Then
                h = "msg2" + hex2(AscB("g")) + "03" + hex2(Index) + hex2(hlp)
            Else
                h = "msg2" + hex2(AscB("g")) + "02" + hex2(Index) + hex2(hlp)
            End If
            Call send(h)
            Debug.Print h
        End If
    End If
End Sub

Private Sub update_entry()
    If entry_name = "floors" Then
        h = entry_field(0)
        If h < 2 Then h = 2
        If h > no_of_floors - 1 Then h = no_of_floors - 1
        floor_no = h
    ElseIf entry_name = "lpos" Then
        lpos = entry_field(0)
    ElseIf entry_name = "lsub" Then
        lsub = entry_field(0)
        Call redraw_2
    ElseIf entry_name = "rele1" Then
        h = entry_field(0)
        all_closed = get_bit(h, 0) Or get_bit(h, 1)
        If all_closed Then
            dax = 0
            dadx = 0
            dbx = 0
            dbdx = 0
        ElseIf get_bit(h, 4) Then ' opening
            dadx = 0.1
        ElseIf get_bit(h, 5) Then ' closing
            dadx = -0.1
        Else
            If dadx > 0 Then
                dax = 1
            ElseIf dadx < 0 Then
                dax = 0
            End If
            dadx = 0
        End If
    ElseIf entry_name = "rele2" Then
        h = entry_field(0)
        svetlo = Not get_bit(entry_field(0), 1)
        If all_closed Then
            dax = 0
            dadx = 0
            dbx = 0
            dbdx = 0
        ElseIf get_bit(h, 4) Then ' opening
            dbdx = 0.1
        ElseIf get_bit(h, 5) Then ' closing
            dbdx = -0.1
        Else
            If dbdx > 0 Then
                dbx = 1
            ElseIf dbdx < 0 Then
                dbx = 0
            End If
            dbdx = 0
        End If
    ElseIf entry_name = "errors" Then
        For i = 1 To max_errors
            got_error(i) = 0
        Next i
        For i = 0 To 20
            h = entry_field(i)
            If h > 0 And h <= max_errors Then got_error(h) = 1
        Next i
        For i = 1 To max_errors
            If got_error(i) = 1 And old_error(i) = 0 Then
                Call add_to_history(errors(i))
            End If
            old_error(i) = got_error(i)
        Next i
    ElseIf entry_name = "smer" Then
        smer = entry_field(0)
        Call redraw_5
    ElseIf entry_name = "calls" Then
        For i = 0 To floor_no - 1
            h = entry_field(i)
            volby(i, 0) = get_bit(h, 0)
            volby(i, 1) = get_bit(h, 1)
            volby(i, 2) = get_bit(h, 2)
        Next i
        Call redraw_1
        Call redraw_3
        Call redraw_4
    ElseIf entry_name = "lcds" Then
        s = ""
        For i = 0 To 31
            g = entry_field(i)
            If g < 8 Then
                s = Mid(spec_string, g + 1, 1)
            Else
                s = Chr(g)
            End If
            Label0(i).Caption = s
            Label0(i).FontUnderline = False
        Next i
        If entry_field(32) = 6 Then
            i = entry_field(33)
            If i >= 0 And i < 32 Then Label0(i).FontUnderline = True
        End If
    End If
End Sub

Private Sub Timer1_Timer()
    rcvd = MSComm1.InBufferCount
    If rcvd > 0 Then
        in_bytes = MSComm1.Input
        For j = LBound(in_bytes) To UBound(in_bytes)
            a = in_bytes(j)
            For i = 0 To in_msg_size - 2
                in_message(i) = in_message(i + 1)
            Next i
            in_message(in_msg_size - 1) = a
            l = in_message(0) = AscB(" ")
            l = l And in_message(1) = AscB("<")
            l = l And in_message(2) = AscB(">")
            l = l And in_message(3) = AscB("<")
            l = l And in_message(4) = AscB(" ")
            If l Then
                state = 1
                entry_name = ""
            Else
                If state = 1 Then
                    If a = 0 Then
                        state = 2
                    Else
                        entry_name = entry_name + Chr(a)
                    End If
                ElseIf state = 2 Then
                    Select Case a
                        Case 0: state = 3
                        Case 1: state = 4
                        Case 2: state = 7
                        Case 3: state = 4
                        Case 4: state = 7
                        Case Else: state = 0
                    End Select
                ElseIf state = 3 Then
                    entry_field(0) = a
                    Call update_entry
                    state = 0
                ElseIf state = 4 Then
                    entry_mul = a
                    If a = 0 Then state = 0 Else state = 5
                ElseIf state = 5 Then
                    entry_len = entry_mul * a
                    entry_ind = 0
                    If a = 0 Then state = 0 Else state = 6
                ElseIf state = 6 Then
                    entry_field(entry_ind) = a
                    entry_ind = entry_ind + 1
                    If entry_ind = entry_len Then
                        Call update_entry
                        state = 0
                    End If
                ElseIf state = 7 Then
                    entry_mul = 1
                    entry_len = a
                    entry_ind = 0
                    If a = 0 Then state = 0 Else state = 6
                Else
                    state = 0
                End If
            End If
        Next j
    End If
End Sub

Private Sub Timer2_Timer()
    If rcvd = 0 Then Call send("debug on")
End Sub

Private Sub Timer3_Timer()
    dax = dax + dadx
    If dax < 0 Then dax = 1
    If dax > 1 Then dax = 0
    dbx = dbx + dbdx
    If dbx < 0 Then dbx = 1
    If dbx > 1 Then dbx = 0
    Call draw_cabin
End Sub

Private Sub Timer4_Timer()
    Call send("debug on")
    h = "msg0" + hex2(AscB("c")) + hex2(5)
    Call send(h)
    pocitadlo = pocitadlo - 1
    If pocitadlo = 0 Then Timer4.Enabled = False
End Sub

Private Sub Timer5_Timer()
    Timer5.Enabled = False      ' total reading time
End Sub

Private Sub Timer6_Timer()
    Timer6.Enabled = False      ' break between writing and checking
End Sub

Private Sub Timer7_Timer()
    Timer7.Enabled = False      ' break after "download"
End Sub
