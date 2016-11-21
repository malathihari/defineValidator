proc ds2;
	package HashFactory / overwrite = yes;
		dcl int codeListNum itemNum;
		dcl char(20) codeListOID codeListCode code extensible;
		dcl char(200) codedValue;
		dcl char(5) extendedValue;
		
		/***********************************/
		/* Import CodeList into hash table */
		/* Method signature: No argument   */
		/***********************************/
		method createCodeList() returns package hash;
			dcl package hash h;
			dcl package sqlstmt stmt;
			
			h = _new_ hash();
			h.keys([codeListNum]);
			h.data([codeListNum codeListOID codeListCode extensible]);
			h.multiData('no');
			h.ordered('yes');
			h.defineDone();
			
			stmt = _new_ sqlstmt();
			stmt.prepare('select codeListNum, codeListOID, codeListCode from _CodeList');
			if stmt.execute() = 0 then do;
				stmt.bindResults([codeListNum codeListOID codeListCode]);
				do while(stmt.fetch() = 0);
					extensible = '';
					h.add();
				end;
			end;
			
			return h;
		end;
		
		/**********************************************************/
		/* Import EnumeratedItem and CodeListItem into hash table */
		/* Method signature: No argument                          */
		/**********************************************************/
		method createTerm() returns package hash;
			dcl package hash h;
			dcl package sqlstmt stmt1 stmt2;
			
			h = _new_ hash();
			h.keys([codeListNum itemNum]);
			h.data([codeListNum itemNum codeListOID codeListCode code codedValue extendedValue]);
			h.multiData('no');
			h.ordered('yes');
			h.defineDone();
		
			stmt1 = _new_ sqlstmt();
			stmt1.prepare('select codeListNum, itemNum, codeListOID, codeListCode, code, codedValue, extendedValue from _EnumeratedItem');
			if stmt1.execute() = 0 then do;
				stmt1.bindResults([codeListNum itemNum codeListOID codeListCode code codedValue extendedValue]);
				do while(stmt1.fetch() = 0);
					h.add();
				end;
			end;
			
			stmt2 = _new_ sqlstmt();	
			stmt2.prepare('select codeListNum, itemNum, codeListOID, codeListCode, code, codedValue, extendedValue from _CodeListItem');
			if stmt2.execute() = 0 then do;
				stmt2.bindResults([codeListNum itemNum codeListOID codeListCode code codedValue extendedValue]);
				do while(stmt2.fetch() = 0);
					h.add();
				end;
			end;

			return h;
		end;
		
		/*************************************************************************/
		/* Import all codedValues with specified CodeList C-Code into hash table */
		/* Method signature: char(20)                                            */
		/*************************************************************************/
		method createTerm(char(20) oid) returns package hash;
			dcl package hash h;
			dcl package sqlstmt stmt1 stmt2;
			
			h = _new_ hash();
			h.keys([codedValue]);
			h.data([codedValue code extendedValue]);
			h.multiData('no');
			h.ordered('yes');
			h.defineDone();
		
			stmt1 = _new_ sqlstmt();
			stmt1.prepare('select codedValue, code, extendedValue from _EnumeratedItem where codeListOID = ?');
			stmt1.setChar(1, strip(oid));
			if stmt1.execute() = 0 then do;
				stmt1.bindResults([codedValue code extendedValue]);
				do while(stmt1.fetch() = 0);
					h.add();
				end;
			end;
				
			stmt2 = _new_ sqlstmt();	
			stmt2.prepare('select codedValue, code, extendedValue from _CodeListItem where codeListOID = ?');
			stmt2.setChar(1, strip(oid));
			if stmt2.execute() = 0 then do;
				stmt2.bindResults([codedValue code extendedValue]);
				do while(stmt2.fetch() = 0);
					h.add();
				end;
			end;

			return h;
		end;
	endpackage;
run;
quit;
