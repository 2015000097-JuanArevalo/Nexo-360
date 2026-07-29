const repo = "2015000097-JuanArevalo/Nexo-360";
const api = `https://api.github.com/repos/${repo}/releases/latest`;
const grid = document.getElementById("download-grid");
const error = document.getElementById("release-error");
document.getElementById("year").textContent = new Date().getFullYear();

const fallback = [
  { name: "NEXO-360-Android.apk", title: "Android", icon: "🤖", description: "APK para teléfonos y tabletas Android." },
  { name: "NEXO-360-Windows.zip", title: "Windows", icon: "🪟", description: "Carpeta completa de la aplicación para Windows 10/11." }
];

async function loadRelease(){
  try{
    const response = await fetch(api,{headers:{Accept:"application/vnd.github+json"}});
    if(!response.ok) throw new Error(`GitHub respondió ${response.status}`);
    const release = await response.json();
    document.getElementById("version").textContent = release.name || release.tag_name;
    document.getElementById("published").textContent = new Intl.DateTimeFormat("es-GT",{dateStyle:"long"}).format(new Date(release.published_at));
    grid.innerHTML = fallback.map((platform)=>{
      const asset = release.assets.find((item)=>item.name === platform.name);
      return `<article class="download-card"><div class="icon">${platform.icon}</div><h3>${platform.title}</h3><p>${platform.description}</p><div class="download-meta"><span>${asset?formatSize(asset.size):"Pendiente"}</span><span>${asset?asset.download_count+" descargas":"Sin archivo"}</span></div><a class="download-button ${asset?"":"disabled"}" href="${asset?asset.browser_download_url:"#"}">${asset?"Descargar":"Aún no publicado"}</a></article>`;
    }).join("");
  }catch(exception){
    document.getElementById("version").textContent = "Versión pendiente";
    document.getElementById("published").textContent = "Crea una etiqueta v2.0.0 para ejecutar el build automático.";
    grid.innerHTML = fallback.map((platform)=>`<article class="download-card"><div class="icon">${platform.icon}</div><h3>${platform.title}</h3><p>${platform.description}</p><div class="download-meta"><span>Pendiente de compilar</span></div><a class="download-button disabled" href="#">Aún no publicado</a></article>`).join("");
    error.hidden=false; error.textContent=`No se encontró una versión publicada: ${exception.message}`;
  }
}
function formatSize(bytes){const units=["B","KB","MB","GB"];let value=bytes,index=0;while(value>=1024&&index<units.length-1){value/=1024;index++;}return `${value.toFixed(index?1:0)} ${units[index]}`;}
loadRelease();
