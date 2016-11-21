%macro ReportWriter(reportDir = &report.);

	%let execDate   = %sysfunc(date(), yymmddn8.);
	%let execTime   = %sysfunc(compress(%sysfunc(time(), tod8.), , dk));
	%let reportPath = &reportDir./validation_report_&execDate._&execTime..csv;

	filename OUTREF "&reportPath.";
	
	%ds2csv(csvfref  = OUTREF
	      , openmode = REPLACE
	      , runmode  = B
	      , colhead  = Y
	      , data     = WORK._REPORT
	      , formats  = N
	      , labels   = N
	      , sepchar  = 2C
	      );

	filename OUTREF clear;
	
%mend;
