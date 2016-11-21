%macro LibraryInitializer(lib = WORK);

	proc delete data = &lib.._ALL_;
	run;

%mend;
