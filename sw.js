/* Ancienne adresse de MAP : ce service worker se désinstalle et renvoie vers la nouvelle adresse. */
self.addEventListener("install",function(){self.skipWaiting();});
self.addEventListener("activate",function(e){e.waitUntil((async function(){
  var k=await caches.keys();await Promise.all(k.map(function(n){return caches.delete(n);}));
  await self.registration.unregister();
  var cl=await self.clients.matchAll({type:"window"});cl.forEach(function(c){c.navigate("https://mapannuaire.github.io/map/");});
})());});
