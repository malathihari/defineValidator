proc ds2;
	package HttpConnecter / overwrite = yes;
		dcl package http h;
		dcl varchar(10) contentType;
		
		/* Constructor */
		method HttpConnecter();
			h = _new_ http();
		end;
		
		/* Set content type to package global variable */
		method setContentType(varchar(10) contentType);
			this.contentType = upcase(contentType);
		end;
		
		/* Get body part from http response */
		/* TODO: SAS PROC DS2 bug. Upper limit length of response is 32767 bytes, so some responses are truncated. E.g. LBTEST, LBTESTCD */
		method execute(varchar(32767) url) returns varchar(32767);
			dcl varchar(32767) character set utf8 body;
			dcl int rc;
			body = '';
			
			/* Execute HEAD method and check HTTP status code */
			h.createHeadMethod(url);
			h.executeMethod();
			
			/* If HTTP status code is 200 OK, execute GET method */
			if h.getStatusCode() = 200 then do;
				h.createGetMethod(url);
				/* Set content type */
				if this.contentType = 'XML' then do;
					h.addRequestHeader('Accept', 'application/xml');
				end;
				else if this.contentType = 'JSON' then do;
					h.addRequestHeader('Accept', 'application/json');
				end;
				h.executeMethod();
				h.getResponseBodyAsString(body, rc);
				if rc = 0 then do;
					*put body; /* Debug */
					return body;
				end;
			end;
			
			return body;
		end;
	endpackage; 
run;
quit;
