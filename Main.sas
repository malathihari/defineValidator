/********************************************************************************
*
* Project           : defineValidator
*
* Program name      : Main.sas
*
* Author            : Ryota Ogawa
*
* Date created      : 2016-11-20
*
* Purpose           : Define-XML validation using SAS DS2 procedure and RESTful web service
*
* Revision History  :
*
* Date         Author        Revision
* 2016-11-20   Ryota Ogawa   Initial release
*
********************************************************************************/

/* SAS system option */
options mprint mprintnest mlogic mlogicnest symbolgen source source2 notes;
options lrecl = 32767;
options varlenchk = nowarn noquotelenmax;
options missing = '';
options compress = no;
options ds2scond = error;

/* Global macro variable declaration */
%let baseUrl = http://52.68.217.226:8080/CDISCWebService/Rest/CT/SDTM; /* RESTful web service */
%let root    = /folders/myfolders/program/defineValidator; /* root directory */
%let macro   = &root./macro;
%let package = &root./package;
%let xmlmap  = &root./xmlmap;
%let define  = &root./define;
%let report  = &root./report;

/* Macro library assignment */
options mautosource sasautos = (SASAUTOS "&macro.");

/* Initialize WORK library */
%LibraryInitializer();

/* Convert define.xml to SAS datasets */
%DefineLoader();

/* Filename assignment */
filename PACK "&package.";

/* Include user-defined package */
%include PACK(ErrorReport);
%include PACK(HashFactory);
%include PACK(JsonParser);
%include PACK(HttpConnecter);
%include PACK(TerminologyValidator);

/* Main */
proc ds2;
	data _null_ / overwrite = yes;
		dcl package ErrorReport report;
		dcl package TerminologyValidator validator;
		
		method init();
			/* Create ErrorReport instance */
			report = _new_ ErrorReport();
			
			/* Create validator instance and execute validation */
			validator = _new_ TerminologyValidator();
			validator.validateCodeList(report);
			validator.validateTerm(report);
		end;
		
		method term();
			/* Output error report to SAS dataset */
			report.outputReport();
		end;
	enddata;
run;
quit;

/* Convert error report to CSV format */
%ReportWriter();


/***** End of Program *****/
