Program ARSEOps;

Uses
  FX;

Type
  TOp = Record
                Name: String;
                Number: Word;
                Password: Word;
                Grade: ShortInt;
              End;

  TOperatorDatabase = File Of TOp;

Var
  Op: TOp;
  Ops: TOperatorDataBase;
  Command: String;

Procedure DisplayHelp;
Begin
  Writeln;
  Writeln('ARSE98 Operator Database Editor');
  Writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  Writeln;
  Writeln('Commands:');
  Writeln('  EXIT                        - Exit the program');
  Writeln('  HELP                        - Show this help');
  Writeln;
End;

Procedure DisplayVersion;
Begin
  Writeln('ARSE98/Ops v1.0');
  Writeln;
End;

Procedure AddEntry;
Var
  TempItem: TOp;
  Result: Char;
  Recs: LongInt;
Begin
  With TempItem
    Do
      Begin
        Writeln;
        Writeln('Adding entry to ops database');
        Writeln;
        Write('    Name: ');
        Readln(Name);
        Write('  Number: ');
        Readln(Number);
        Write('Password: ');
        Readln(Password);
        Write('   Grade: ');
        Readln(Grade);
      End;
  Writeln;
  Write('Commit this op to database? [y/n]');
  Readln(Result);
  If Result In ['y','Y']
    Then
      Begin
        Recs := FileSize(Ops);
        Seek(Ops,Recs+1);
        Write(Ops,TempItem);
      End;
  Writeln;
End;

Procedure ListDataBase;
Var
  TempItem: TOp;
Begin
  Writeln;
  Writeln('Listing ',FileSize(Ops),' ops...');
  Seek(Ops,0);
  Repeat
    Read(Ops, TempItem);
    Writeln('-----------');
    Writeln('Name: ',TempItem.Name);
    Writeln('Number:',TempItem.Number);
    Seek(Ops,FilePos(Ops)+1);
  Until EOF(Ops);
  Writeln;
End;

Begin
  Writeln;
  Writeln('ARSE98 Item Database Management');
  Writeln;
  Write('Attempting to open the database...');
  {$I-}
  Assign(Ops,'ops.til');
  Reset(Ops);
  If IOResult <> 0
    Then
      Begin
        Writeln('failed.');
        Writeln('Creating a sample database (1 item)');
        Writeln;
        With Op
          Do
            Begin
              Name := 'James Seward';
              Number := 3007;
              Password := 0000;
              Grade := 30;
            End;
        Close(Ops);
        Assign(Ops,'ops.til');
        Rewrite(Ops);
        Write(Ops,Op);
        Close(Ops);
        Writeln('Done, terminating');
        Halt;
      End;
  Writeln(' succeeded (',FileSize(Ops),' ops)');
  Repeat
    Write('ARSE98:/Ops>');
    Readln(Command);
    Command := UpCaseString(Command);
		If Command = 'HELP'
      Then DisplayHelp;
    If Command = 'VER'
      Then DisplayVersion;

    If Command = 'ADD'
      Then AddEntry;
    If Command = 'LIST'
      Then ListDatabase;

    If (Command = 'CD..') Or (Command = 'CD ..') Or (Command = 'CD /')
      Then Writeln('Bad command. Cannot step up from this level');
  Until Command='EXIT';
End.
