Program ARSE98; {Advanced Retail System Emulator}

Uses
  FX, Crt;

Const
  TillColour = Blue;

Type
  TItem = Record
            Name: String;
            Cost: Integer;
            VAT: Boolean;
            ClubCard: Boolean;
            BonusPoints: Integer;
          End;

  TItemDatabase = File Of TItem;

  TOperator = Record
                Name: String;
                Number: Word;
                Password: Word;
                Grade: ShortInt;
              End;

  TOperatorDatabase = File Of TOperator;

Var
  Items: TItemDataBase;
  Operators: TOperatorDatabase;
  Operator: TOperator;

  SaveRolls: Boolean;
  Noisy: Boolean;

Procedure FileError(Desc: String; FileName: String);
Begin
  Writeln('Error (01): Cannot access a required file');
  Writeln('            Filename: ',FileName);
  Writeln('            Action: ',Desc);
  Writeln;
  Halt;
End;

Procedure StartUp;
Begin
  TextMode(Co80 + Font8x8);
  Banner('ARSE98 Starting, please wait...',Yellow,Blue);
  Writeln('� Opening files...');
  {$I-}
  Assign(Items,'items.til');
  Reset(Items);
  If IOResult <> 0
    Then FileError('Opening items database','items.til');
  Writeln(' � Opened items database');
  Assign(Operators,'ops.til');
  Reset(Operators);
  If IOResult <> 0
    Then FileError('Opening operators database','ops.til');
  Writeln(' � Opened operators database');
End;

Procedure ReadCommandLine;
Begin
  Writeln('� Checking commandline');
End;

Procedure Display(Where: Integer; What: String);
Begin
  Case Where Of
    0: Begin GotoXY(24,3); Write('                          '); GotoXY(24,3); TextColor(TillColour); End;
  End;

  Write(What);
End;

Procedure DrawKeyBoard;
  Procedure DisplayColouredLine(Line : String);
  {! Means Yellow; @ means Gray; # means Blue; � means white; % means Normal}
  {^ is Grn; & is Brwn; ( is wht; ) is red; ~ is Pink}
  {> means one char red (shortcut)}

  {
   +-----------------------------------------------------------+
   |                     +12345678901234567890123704+          |
   |                     |                          |          |
   |                     +--------------------------+          |
   +---------+----+----+----+----+----+----+----+----+----+----+
   |!Credit/  %|! +  %|!Void%|!    %|!Void%|!Refd%|!Paid%|!Till%|!ROA %|# Q  %|# O  %|
   |! Debit   %|!    %|!Last%|!    %|!    %|!    %|!Outs%|!Pick%|!    %|#Pric%|#  N %|
   +----+----+----+----+----+----+----+----+----+----+----+----+
   |!Tesc%|!Prnt%|@ C  %|@ 7  %|@ 8  %|@ 9  %|# Weight  %|#Prod%|#Qty %|�Grn %|#Save%|
   |!Stmp%|!    %|@    %|@    %|@    %|@    %|#         %|#    %|#    %|�Tckt%|#Load%|
   +----+----+----+----+----+----+---------+----+----+----+----+
   |!Cheq%|!Club%|!T   %|@ 4  %|@ 5  %|@ 6  %|#   No    %|#Home%|#Meat%|#    %|#Tran%|
   |!    %|!Card%|! o  %|@    %|@    %|@    %|#         %|#Wear%|#    %|#    %|#OnOf%|
   +----+----+!  t %+----+----+----+---------+----+----+----+----+
   |!Staf%|!Vouc%|!   a%|@ 1  %|@ 2  %|@ 3  %|#         %|#Groc%|#Bake%|#Forc%|#Temp%|
   |!Disc%|!    %|!   l%|@    %|@    %|@    %|#  Enter  %|#    %|#    %|#Off %|#OnOf%|
   +----+----+----+----+----+----+         +----+----+----+----+
   |!  Cash   %|@         0         %|#   Yes   %|#Mag %|#Wine%|#Help%|#Sign%|
   |!         %|@                   %|#         %|#News%|#Spir%|#    %|#OnOf%|
   +---------+-------------------+---------+----+----+----+----+
  }
  Var
    i : Integer;
    InRed : Boolean;
    InGray : Boolean;
    InRedBright : Boolean;
  Begin
    TextColor(LightGray);
    TextBackGround(Black);
    InRed := False;
    InRedBright := False;
    HighResBrightBack;
    For i := 1 To Length(Line)
      Do Begin
        Case Line[i] Of
          '!': Begin TextColor(Black+Blink); TextBackGround(Yellow); InGray := False;End;
          '@': Begin TextColor(Black); TextBackGround(LightGray); InGray := False;End;
          '#': Begin TextColor(Black+Blink); TextBackGround(Cyan); InGray := False;End;
          '�': Begin TextColor(Black+Blink); TextBackGround(White); InGray := False;End;
          '%': Begin TextColor(LightGray); TextBackGround(Black); InGray := True; End;
          '^': Begin TextColor(Black+Blink); TextBackGround(Green); InGray := False; End;
          '&': Begin TextColor(Black+Blink); TextBackground(Brown); InGray := False; ENd;
          '(': Begin TextCOlor(Black+Blink); TextBackground(White); InGray := False; End;
          ')': Begin TextColor(Black+Blink); TextBackGround(Red); InGray := False; ENd;
          '~': Begin TextColor(Black+Blink); TextBackground(LightMagenta); InGray := False; End;
          '>': Begin InRed := True; End;
          '<': Begin InRed := True; InRedBright := True; End;
          Else Begin
            If InRed
              Then Begin
                If InRedBright
                  Then TextColor(LightRed+Blink)
                  Else TextColor(Red+Blink);
                Write(Line[i]);
                InRed := False;
                InRedBright := False;
              End
            Else
              Write(Line[i]);

            If InGray
              Then TextColor(LightGray)
              Else TextColor(Black+Blink);
          End;
        End;
      End;
    Writeln;
  End;

  Begin

  {
   +-----------------------------------------------------------+
   |                     +12345678901234567890123704+          |
   |                     |                          |          |
   |                     +--------------------------+          |
   +---------+----+----+----+----+----+----+----+----+----+----+
   |Credit/  | +  |Void|    |Void|Refd|Paid|Till|ROA | Q  | O  |
   | Debit   |    |Last|    |    |    |Outs|Pick|    |Pric|  N |
   +----+----+----+----+----+----+----+----+----+----+----+----+
   |Tesc|Prnt| C  | 7  | 8  | 9  | Weight  |Prod|Qty |Grn |Save|
   |Stmp|    |    |    |    |    |         |    |    |Tckt|Load|
   +----+----+----+----+----+----+---------+----+----+----+----+
   |Cheq|Club|T   | 4  | 5  | 6  |   No    |Home|Meat|    |Tran|
   |    |Card| o  |    |    |    |         |Wear|    |    |OnOf|
   +----+----+  t +----+----+----+---------+----+----+----+----+
   |Staf|Vouc|   a| 1  | 2  | 3  |         |Groc|Bake|Forc|Temp|
   |Disc|    |   l|    |    |    |  Enter  |    |    |Off |OnOf|
   +----+----+----+----+----+----+         +----+----+----+----+
   |  Cash   |         0    |    |   Yes   |Mag |Wine|Help|Sign|
   |         |              | .  |         |News|Spir|    |OnOf|
   +---------+-------------------+---------+----+----+----+----+
  }
    DisplayColouredLine('%�����������������������������������������������������������ͻ    Other keys:');
    DisplayColouredLine('�                     ��������������������������ͻ          �     %* Paid Outs');
    DisplayColouredLine('�                     �                          �          �     %, Till Pickup');
    DisplayColouredLine('�                     ��������������������������ͼ          �     %? Help');
    DisplayColouredLine('�����������������������������������������������������������͹     %'' %Training');
    DisplayColouredLine
    ('�!C>redit/  %�! >+  %�!Vo>id%�!    %�!>Void%�!Re>fd%�!Paid%�!Till%�!RO>A %�# >Q  %�# O  %�     %] Voucher');
    DisplayColouredLine
    ('�! Debit   %�!    %�!Last%�!    %�!    %�!    %�!Outs%�!Pick%�!    %�#Pric%�#  N %�     %[ Wine Spirit');
    DisplayColouredLine('�����������������������������������������������������������͹');
    DisplayColouredLine('�!T>esc%�!>Prnt%�@ >C  %�@ 7  %�@ 8  %�@ 9  %�# >Weight  %�^Pro-%�#Qt>y %��Grn %�#Save%�');
    DisplayColouredLine('�!Stmp%�!    %�@    %�@    %�@    %�@    %�#         %�^d>uce%�#    %��Tc>kt%�#>Load%�');
    DisplayColouredLine('�����������������������������������������������������������͹');
		DisplayColouredLine('�!Che>q%��C>lub%�!>  T %�@ 4  %�@ 5  %�@ 6  %�#   No    %�&H>ome%�)>Meat%�#    %�#Tran%�');
		DisplayColouredLine('�!    %��Card%�!  o %�@    %�@    %�@    %�#  >D>e>l    %�&Wear%�)    %�#    %�#OnOf%�');
		DisplayColouredLine('���������͹!  t %��������������������������������������������͹');
		DisplayColouredLine('�!Staf%�!Vouc%�!   a%�@ 1  %�@ 2  %�@ 3  %�#         %�@>Groc%�~<Bake%�#Forc%�#T>emp%�');
		DisplayColouredLine('�!>Disc%�!    %�!   l%�@    %�@    %�@    %�#  >E>n>t>e>r  %�@    %�~    %�#Off %�#OnOf%�');
    DisplayColouredLine('�����������������������������͹#         %�������������������͹');
    DisplayColouredLine('�!  Cas>h   %�@         0    %�@    %�#   Yes   %�(Mag %�!Wine%�#Help%�#>Sign%�');
    DisplayColouredLine('�!         %�@              %�@ >.  %�#         %�(>News%�!Spir%�#    %�#OnOf%�');
    DisplayColouredLine('�����������������������������������������������������������ͼ');
End;

Begin
  StartUp;
  ReadCommandLine;
  Fade;
  TextMode(Co80+Font8x8);
  DrawKeyboard;
  Display(0,' Welcome to ARSE98');
  Delay(5000);
  Display(0,'** SIGNED OFF **');
End.