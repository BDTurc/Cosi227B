.phony: all pre-build clean

all: pre-build ap/clusters.txt ap/centers.txt spectral/clusters.txt viz_ap.html viz_spectral.html

pre-build:
	pip3 install -r requirements.txt

ap/clusters.txt ap/centers.txt: results
	python3 ap/cluster.py

spectral/clusters.txt: results
	python3 spectral/cluster.py

viz_ap.html: ap/clusters.txt ap/centers.txt
	python3 ap/to_dumb_html.py > viz_ap.html

viz_spectral.html: spectral/clusters.txt
	python3 spectral/to_dumb_html.py > viz_spectral.html


clean:
	rm -f ap/clusters.txt
	rm -f ap/centers.txt
	rm -f spectral/clusters.txt
	rm -f *.html
