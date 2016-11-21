proc ds2;
	package JsonParser / overwrite = yes;
		dcl char(20) codeListCode code codeListExtensible; 
		dcl char(200) codedValue;
		
		/****************************************************************/
		/* Parse JSON response with CodeList and store into hash object */
		/****************************************************************/
		method parseCodeList(varchar(32767) jsonText) returns package hash;
			dcl package hash h;
			dcl package json j;
			dcl int rc tokenType parseFlags;
			dcl char(200) token;
			
			/* Instantiate hash object for return */
			h = _new_ hash();
			h.keys([codeListCode]);
			h.data([codeListExtensible]);
			h.multiData('no');
			h.defineDone();
			
			/* Instantiate json parser */
			j = _new_ json();
			j.createParser(jsonText);
			rc = 0;
			
			do while(rc = 0);
				j.getNextToken(rc, token, tokenType, parseFlags);
				
				/* Key: Request */
				if upcase(token) = 'REQUEST' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.codeListCode = scan(token, -1, '/');
				end;
				/* Key: CodeListExtensible */
				if upcase(token) = 'CODELISTEXTENSIBLE' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.codeListExtensible = token;
				end;
			end;

			h.add();
			j.destroyParser();
			return h;
		end;
		
		/************************************************************/
		/* Parse JSON response with Term and store into hash object */
		/************************************************************/
		method parseTerm(varchar(32767) jsonText) returns package hash;
			dcl package hash h;
			dcl package json j;
			dcl int rc tokenType parseFlags;
			dcl char(200) token;
		
			/* Instantiate hash object for return */
			h = _new_ hash();
			h.keys([codeListCode code]);
			h.data([codedValue]);
			h.multiData('no');
			h.defineDone();
		
			/* Instantiate json parser */
			j = _new_ json();
			j.createParser(jsonText);
			rc = 0;
		
			do while(rc = 0);
				j.getNextToken(rc, token, tokenType, parseFlags);
				
				/* Key: Request */
				if upcase(token) = 'REQUEST' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.codeListCode = scan(token, -2, '/');
					this.code = scan(token, -1, '/');
				end;
				/* Key: CodeListExtensible */
				if upcase(token) = 'CODEDVALUE' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.codedValue = token;
				end;
			end;

			h.add();
			j.destroyParser();
			return h;
		end;

		/****************************************************************/
		/* Parse JSON response with AllTerms and store into hash object */
		/****************************************************************/
		method parseAllTerms(varchar(32767) jsonText) returns package hash;
			dcl package hash h;
			dcl package json j;
			dcl int rc tokenType parseFlags;
			dcl char(200) token;
			
			/* Instantiate hash object for return */
			h = _new_ hash();
			h.keys([codedValue]);
			h.data([codeListCode code codedValue]);
			h.multiData('no');
			h.defineDone();
						
			/* Instantiate json parser */
			j = _new_ json();
			j.createParser(jsonText);
			rc = 0;
			
			do while(rc = 0);
				j.getNextToken(rc, token, tokenType, parseFlags);
				
				/* Key: Request */
				if upcase(token) = 'REQUEST' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.codeListCode = scan(token, -2, '/');
				end;
				/* Key: ExtCodeID */
				if upcase(token) = 'EXTCODEID' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.code = token;
				end;
				/* Key: CodedValue */
				if upcase(token) = 'CODEDVALUE' then do;
					j.getNextToken(rc, token, tokenType, parseFlags);
					this.codedValue = token;
					
					h.add();
				end;
			end;
			
			j.destroyParser();
			return h;
		end;
	endpackage; 
run;
quit;
