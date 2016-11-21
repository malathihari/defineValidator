proc ds2;
	package TerminologyValidator / overwrite = yes;
		/* Hash table and iterator to provide terminology in Define-XML */
		dcl package hash defineCodeList defineTerm defineAllTerms;
		dcl package hiter defineCodeListIterator defineTermIterator defineAllTermsIterator;
		
		/* Hash table and iterator to provide terminology in Standard CDISC CT */
		dcl package hash standardCodeList standardTerm standardAllTerms;
		
		/* Global variables to store hash key and data */
		dcl int clnum inum;
		dcl char(20) oid clcode icode ext;
		dcl char(200) cdvalue;
		dcl char(5) extflag;
		
		/******************************************************************************************************/
		/*                                      HASH OBEJCT DEFINITIONS                                       */
		/*----------------------------------------------------------------------------------------------------*/
		/* HASH: defineCodeList   | KEYS: clnum        | DATA: clnum oid clcode ext                           */
		/* HASH: defineAllTerms   | KEYS: clnum inum   | DATA: clnum inum oid clcode icode cdvalue extflag    */
		/* HASH: defineTerm       | KEYS: cdvalue      | DATA: cdvalue icode extflag                          */
		/* HASH: standardCodeList | KEYS: clcode       | DATA: ext                                            */
		/* HASH: standardAllTerms | KEYS: cdvalue      | DATA: clcode icode cdvalue                           */
		/* HASH: standardTerm     | KEYS: clcode icode | DATA: cdvalue                                        */
		/******************************************************************************************************/
		
		dcl package HashFactory factory;
		dcl package HttpConnecter conn;
		dcl package JsonParser parser;
		
		/* Constructor */
		method TerminologyValidator();
			factory = _new_ HashFactory();
			conn = _new_ HttpConnecter();
			conn.setContentType('JSON');
			parser = _new_ JsonParser();
		end;
	
		/* Validate CodeList and return validation error to report instance */
		method validateCodeList(in_out package ErrorReport report);
			dcl varchar(32767) request response;
			
			/* Get CodeList hash instance from Define-XML */
			defineCodeList = factory.createCodeList();
			defineCodeListIterator = _new_ hiter('defineCodeList');
			
			do while(defineCodeListIterator.next([clnum oid clcode ext]) = 0);
				if not missing(clcode) then do;
					/* Get CodeList from RESTful web service */
					request = catx('/', %tslit(&baseUrl.), clcode);
					response = conn.execute(request);
					
					/* If CodeList Code does not exist in CDISC CT, throw DD0033 error */
					if missing(response) then do;
						report.addError('DD0033', oid, clcode, '', '', cats('Unknown NCI Code value for Codelist [', oid, ']'));
					end;
					
					/* If CodeList Code exists in CDISC CT, get extensible flag from CDISC CT. */
					else do;
						standardCodeList = parser.parseCodeList(response);
						if standardCodeList.find([clcode], [ext]) = 0 then do;
							defineCodeList.replace([clnum], [clnum oid clcode ext]);
						end;
					end;
				end;
			end;
			
			do while(defineCodeListIterator.next([clnum oid clcode ext]) = 0);
				if not missing(clcode) and not missing(ext) then do;
					/* Get Term hash instance with specified CodeList C-Code from Define-XML */
					defineTerm = factory.createTerm(strip(oid));
					defineTermIterator = _new_ hiter('defineTerm');
				
					/* Get AllTerms hash instance with specified CodeList C-Code from RESTful web service */
					request = catx('/', %tslit(&baseUrl.), clcode, 'AllTerms', 'CodedValue');
					response = conn.execute(request);
					standardAllTerms = parser.parseAllTerms(response);
					
					/* If CodeList is non-extensible and there is CodedValue does not belong to CDISC CT, throw DD0024 error */
					if upcase(ext) = 'NO' then do;
						do while(defineTermIterator.next([cdvalue icode extflag]) = 0);
							if standardAllTerms.check([cdvalue]) ne 0 then do;
								report.addError('DD0024', oid, clcode, '', cdvalue, cats('Invalid Term in Codelist [', oid, ']'));
							end;
						end;
					end;
					
					/* If CodeList is extensible and there is CodedValue that have neither C-Code nor def:ExtendedValue, throw DD0029 error */
					if upcase(ext) = 'YES' then do;
						do while(defineTermIterator.next([cdvalue icode extflag]) = 0);
							if standardAllTerms.check([cdvalue]) ne 0 and missing(icode) and missing(extflag) then do;
								report.addError('DD0029', oid, clcode, '', cdvalue, 'Required attribute def:ExtendedValue is missing or empty');
							end;
						end;
					end;
					
					/* If CodeList corresponding to the Term exists in CDISC CT and C-Code of Term does not exist, throw DD0032 error */
					do while(defineTermIterator.next([cdvalue icode extflag]) = 0);
						if standardAllTerms.check([cdvalue]) = 0 and missing(icode) then do;
							report.addError('DD0032', oid, clcode, '', cdvalue, cats('Missing NCI Code for Term in Codelist [', oid, ']'));
						end;
					end;
				end;
			end;
		end;
		
		/* Validate Term and return validation error to report instance */
		method validateTerm(in_out package ErrorReport report);
			dcl varchar(32767) request response;
			dcl char(200) def_cdvalue; /* CodedValue in Define-XML */
		
			/* Get all Terms hash instance from Define-XML */
			defineAllTerms = factory.createTerm();
			defineAllTermsIterator = _new_ hiter('defineAllTerms');
			
			do while(defineAllTermsIterator.next([clnum inum oid clcode icode cdvalue extflag]) = 0);
				if not missing(clcode) and not missing(icode) then do;
					/* If CodeList corresponding to the Term exists in CDISC CT, check DD0034 */
					if defineCodeList.find([clnum], [clnum oid clcode ext]) = 0 and not missing(ext) then do;
						/* Get Term from RESTful web service */
						request = catx('/', %tslit(&baseUrl.), clcode, icode);
						response = conn.execute(request);
				
						/* If Term Code does not exist in CDISC CT, throw DD0034 error */
						if missing(response) then do;
							report.addError('DD0034', oid, clcode, icode, cdvalue, cats('Unknown NCI Code value for Term in Codelist [', oid, ']'));
						end;
						
						/* If Term Code exists in CDISC CT but CodedValue is different between Define-XML and CDISC CT, throw DD0028 error */
						else do;
							def_cdvalue = cdvalue;
							standardTerm = parser.parseTerm(response);
							if standardTerm.find([clcode icode], [cdvalue]) = 0 and def_cdvalue ne cdvalue then do;
								report.addError('DD0028', oid, clcode, icode, def_cdvalue, cats('Term/NCI Code mismatch in Codelist [', oid, ']'));
							end;
						end;						
					end;
				end;
			end;			
		end;
	endpackage;
run;
quit;
