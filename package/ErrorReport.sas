proc ds2;
	package ErrorReport / overwrite = yes;
		dcl package hash h;
		declare char(10) ID;
		declare char(20) CODELIST_OID;
		declare char(10) CODELIST_CODE;
		declare char(10) ITEM_CODE;
		declare char(200) ITEM_VALUE;
		declare char(200) MESSAGE;
		
		/* Constructor */
		method ErrorReport();
			h = _new_ hash();
			h.keys([ID]);
			h.data([ID CODELIST_OID CODELIST_CODE ITEM_CODE ITEM_VALUE MESSAGE]);
			h.multidata('yes');
			h.ordered('yes');
			h.definedone();
		end;
		
		/* Add error report to hash instance */
		method addError(char(10) ID, char(20) CODELIST_OID, char(10) CODELIST_CODE, char(10) ITEM_CODE, char(200) ITEM_VALUE, char(200) MESSAGE);
			this.ID = ID;
			this.CODELIST_OID = CODELIST_OID;
			this.CODELIST_CODE = CODELIST_CODE;
			this.ITEM_CODE = ITEM_CODE;
			this.ITEM_VALUE = ITEM_VALUE;
			this.MESSAGE = MESSAGE;
			h.add();
		end;
		
		/* Output error report into SAS dataset */
		method outputReport();
			h.output('_report');
		end;
	endpackage; 
run;
quit;
