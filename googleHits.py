# Ricky Savjani
# Scrape google searches for readability of top N hits
# 1/14/2019
# rsavjani@gmail.com

# package dependencies
# googlesearch: https://pypi.org/project/google/
# Beautifulsoup4: https://pypi.org/project/beautifulsoup4/
# requests: https://pypi.org/project/requests/

# Define params
keyword = "cancer immunotherapy"
N = 150

# get the top N URLs from a Google search
from googlesearch import search 
urls = search(keyword, tld="com", num=N, stop=1, pause=2) 

# save the websites into a list
print "here are the top " + str(N) + " urls:"
count = 0
urls_lst = []
for x in urls:
    url = x
    urls_lst.append(url)
    print str(count+1) + ": " + url
    count = count + 1

# extract only top N URLs
urls_lst = urls_lst[0:N]

# save the websites into a file
outf = open(keyword + ".txt", "w")

for x in urls_lst:
    outf.write(x)
    outf.write("\n")
outf.close()

# get the text from the websites and save to File
from bs4 import BeautifulSoup
import requests
count = 0
for url in urls_lst:
    r_url  = requests.get(url, verify=False)
    data = r_url.text
    soup = BeautifulSoup(data)
    
    # kill all script and style elements
    for script in soup(["script", "style"]):
        script.extract()    # rip it out

    fileName = "rawTxt/" + str(count) + "_" + keyword + ".html"
    open(fileName, 'wb').write(r_url.content)

    # get text
    text = soup.body.get_text()

    # break into lines and remove leading and trailing space on each
    lines = (line.strip() for line in text.splitlines())
    
    # break multi-headlines into a line each
    chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
    
    # drop blank lines
    text = '\n'.join(chunk for chunk in chunks if chunk)

    # save clean text 
    txtFileName = "cleanTxt/" + str(count) + "_" + keyword + ".txt"
    open(txtFileName, 'w').write(text.encode('utf-8'))

    count = count + 1
