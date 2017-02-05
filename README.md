# defineValidator

CDISC Define-XML validator using SAS DS2 procedure and RESTful web service.

## Description

This is an experimental SAS program to validate the CodeList elements of CDISC Define-XML for SDTM.

For the purpose of getting information about CDISC Controlled Terminology, RESTful web service is used.

Now supported validation rule ID is as below. Please see the PMDA Validation Rules for details of the rules.

* DD0024: Invalid Term in Codelist &lt;codelist&gt;
* DD0028: Term/NCI Code mismatch in Codelist &lt;codelist&gt;
* DD0029: Required attribute def:ExtendedValue is missing or empty
* DD0032: Missing NCI Code for Term in Codelist &lt;codelist&gt;
* DD0033: Unknown NCI Code value for Codelist &lt;codelist&gt;
* DD0034: Unknown NCI Code value for Term in Codelist &lt;codelist&gt;

## Requirement

* Base SAS 9.4

Use of [SAS University Edition](http://www.sas.com/en_us/software/university-edition.html) is recommended.

* An environment that you can access to the following web server.

[CDISC Controlled Terminology RESTful Web Service](http://52.68.217.226:8080/CDISCWebService/)

## Usage

1. Set the Define-XML file in **define** folder.
2. Change the value of **root** global macro variable of **Main.sas** in accordance with your environment.
3. Execute **Main.sas** program with Base SAS 9.4.
4. Validation report is saved as CSV format in **report** folder.

## Known Issues

Due to the constraint of the specification of HTTP predefined package in SAS DS2 procedure, only the HTTP message body up to 32,767 bytes can be received by HTTP GET method.

Therefore, the validation rules relative to the following CodeList C-Code cannot be executed normally.

* C65047: LBTESTCD (Laboratory Test Code)
* C67154: LBTEST (Laboratory Test Name)
* C85491: MICROORG (Microorganism)

## References

* [CDISC Define-XML](https://www.cdisc.org/standards/foundational/define-xml)
* [CDISC Controlled Terminology](https://www.cancer.gov/research/resources/terminology/cdisc)
* [PMDA Study Data Validation Rules](http://www.pmda.go.jp/english/review-services/reviews/advanced-efforts/0002.html)
* [SAS 9.4 DS2 Language Reference, Sixth Edition](https://support.sas.com/documentation/cdl/en/ds2ref/68052/HTML/default/viewer.htm)
