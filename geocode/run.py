import json,urllib.request,urllib.parse,time,sys
src=json.load(open("geocode/addresses.json",encoding="utf-8"))
try: out=json.load(open("geocode/results.json",encoding="utf-8"))
except Exception: out={}
def q(url):
    req=urllib.request.Request(url,headers={"User-Agent":"annuaire-sante-mentale-geocoder"})
    with urllib.request.urlopen(req,timeout=30) as r: return json.load(r)
for k,addr in src.items():
    if k in out and out[k].get("addr")==addr: continue
    res={"addr":addr}
    try:
        j=q("https://api-adresse.data.gouv.fr/search/?limit=1&q="+urllib.parse.quote(addr))
        if j.get("features"):
            f=j["features"][0];lon,lat=f["geometry"]["coordinates"];p=f["properties"]
            res.update(lat=lat,lon=lon,label=p.get("label"),score=p.get("score"),type=p.get("type"),src="ban")
    except Exception as e: res["err"]=str(e)
    if "lat" not in res:
        try:
            time.sleep(1.1)
            j=q("https://nominatim.openstreetmap.org/search?format=json&limit=1&q="+urllib.parse.quote(addr))
            if j: res.update(lat=float(j[0]["lat"]),lon=float(j[0]["lon"]),label=j[0]["display_name"],src="osm")
        except Exception as e: res["err2"]=str(e)
    out[k]=res
json.dump(out,open("geocode/results.json","w",encoding="utf-8"),ensure_ascii=False,indent=1)
print(len(out),"adresses")
