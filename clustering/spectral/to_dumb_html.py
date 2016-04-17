exemp = dict()
clusters = dict()

def img_to_tag(url):
    return "<img width=\"100px\" src=\"" + url + "\" />"


with open("spectral/clusters.txt") as f:
    for l in f:
        fields = l.split()
        url = fields[0]
        cluster = fields[1]

        if cluster not in clusters:
            clusters[cluster] = []
            
        clusters[cluster].append(url)


print("<html><head><title>Clusters</title></head><body>")
        
for k, v in clusters.items():
    print("<h1>Cluster", k, "<br/>")

    for i in v:
        print(img_to_tag(i))
    print("<hr>")
          

print("</body></html>")
