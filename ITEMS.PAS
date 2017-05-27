Program ARSEItems;

Uses
  FX;

Type
  TItem = Record
            Name: String;
            Code: Comp;
            Cost: Integer;
            VAT: Boolean;
            ClubCard: Boolean;
            BonusPoints: Integer;
          End;

  TItemDatabase = File Of TItem;

Var
  Item: TItem;
  Items: TItemDataBase;
  Command: String;

Procedure DisplayHelp;
Begin
  Writeln;
  Writeln('ARSE98 Items Database Editor');
  Writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  Writeln;
  Writeln('Commands:');
  Writeln('  EXIT                        - Exit the program');
  Writeln('  HELP                        - Show this help');
  Writeln;
End;

Procedure DisplayVersion;
Begin
  Writeln('ARSE98/Items v1.0');
  Writeln;
End;

Procedure AddEntry;
Var
  TempItem: TItem;
  Result: Char;
  Recs: LongInt;
Begin
  With TempItem
    Do
      Begin
        Writeln;
        Writeln('Adding entry to items database');
        Writeln;
        Write('   Name: ');
        Readln(Name);
        Write('Barcode: ');
        Readln(Code);
        Write('  Pence: ');
        Readln(Cost);
        Writeln('    VAT: No');
        VAT := False;
        Writeln('Cubcard: Yes');
        Clubcard := False;
        Writeln('Bonuses: 0');
        BonusPoints := 0;
      End;
  Writeln;
  Write('Commit this item to database? [y/n]');
  Readln(Result);
  If Result In ['y','Y']
    Then
      Begin
        Recs := FileSize(Items);
        Seek(Items,Recs+1);
        Write(Items,TempItem);
      End;
  Writeln;
End;

Procedure ListDataBase;
Var
  TempItem: TItem;
Begin
  Writeln;
  Writeln('Listing ',FileSize(Items),' items...');
  Seek(Items,0);
  Repeat
    Read(Items, TempItem);
    Writeln('-----------');
    Writeln('Name: ',TempItem.Name);
    Writeln('Barcode:',TempItem.Code);
    Seek(Items,FilePos(Items)+1);
  Until EOF(Items);
  Writeln;
End;

Begin
  Writeln;
  Writeln('ARSE98 Item Database Management');
  Writeln;
  Write('Attempting to open the database...');
  {$I-}
  Assign(Items,'items.til');
  Reset(Items);
  If IOResult <> 0
    Then
      Begin
        Writeln('failed.');
        Writeln('Creating a sample database (1 item)');
        Writeln;
        With Item
          Do
            Begin
              Name := 'Sula BlackCrnt';
              Code := 4003455065286.0;
              Cost := 49;
              VAT := True;
              ClubCard := True;
              BonusPoints := 0;
            End;
        Close(Items);
        Assign(Items,'items.til');
        Rewrite(Items);
        Write(Items,Item);
        Close(Items);
        Writeln('Done, terminating');
        Halt;
      End;
  Writeln(' succeeded (',FileSize(Items),' items)');
  Repeat
    Write('ARSE98:/Items>');
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
