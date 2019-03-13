

scao_Bot.owl: ./imports/efo-edit_import.owl ./imports/upper_terms.csv ./imports/lower_terms.csv
	$(ROBOT) extract --method MIREOT --input ./imports/efo-edit_import.owl --upper-terms ./imports/upper_terms.csv --lower-terms ./imports/lower_terms.csv  -N all  --o scao_Bot.owl

scao-slim.owl: scao_Bot.owl
	$(ROBOT) query -i scao_Bot.owl --format ttl --construct $(SPARQLDIR)slim_construct.sparql scao-slim.owl

#scao-slim1.owl: scao-slim.owl $(IMPORTSDIR)efo-edit_import.owl
#	$(ROBOT) merge -i $(IMPORTSDIR)efo-edit_import.owl -i scao-slim.owl --include-annotations true annotate --ontology-iri http://purl.obolibrary.org/obo/scao reduce --reasoner ELK -o scao-slim1.owl



#scao-slim2.owl:	$(IMPORTSDIR)efo-edit_import.owl $(IMPORTSDIR)efo-edit_terms.tsv
#	$(ROBOT) extract -i $(IMPORTSDIR)efo-edit_import.owl -T $(IMPORTSDIR)efo-edit_terms.tsv --method BOT -o $@












## creating the slim
## SPARQL query
## extracts the URIs and attaches inSubset scao_slim annotation to each term

#scao-slim2.owl: scao_Bot.owl
#	$(ROBOT) query -i scao_Bot.owl --format ttl --construct $(SPARQLDIR)slim_construct.sparql scao-slim2.owl



#scao-prefixed.owl: scao_Bot.owl scao-slim.owl
#		$(ROBOT) merge -i scao_Bot.owl -i scao-slim.owl --prefix $(PREFIX) -o $@


## -- import targets --

$(IMPORTSDIR)efo-edit_import.owl:
	curl https://raw.githubusercontent.com/EBISPOT/efo/master/src/ontology/efo-edit.owl > imports/efo-edit_import.owl



# ----------------------------------------
# Main release targets
# ----------------------------------------

# by default we use Elk to perform a reason-relax-reduce chain
# after that we annotate the ontology with the release versionInfo
$(SRC): scao-slim1.owl scao-slim2.owl
	$(ROBOT) merge -i scao-slim1.owl -i scao-slim2.owl --prefix $(PREFIX) -o $@

$(ONT).owl: $(SRC)
	$(ROBOT) reason --input $< --reasoner ELK \
		 relax \
		 reduce -r ELK \
		 remove --select imports \
	         merge  $(patsubst %, -i %, $(IMPORT_OWL_FILES))  \
	         annotate --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@

# requires robot 1.2
$(ONT)-base.owl: $(SRC)
	$(ROBOT) remove --trim false --input $< --select imports \
annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@ &&\
	echo "$(ONT)-base.owl successfully created."




