import { initializeApp } from "https://www.gstatic.com/firebasejs/11.10.0/firebase-app.js";
import { getFirestore, collection, doc, onSnapshot, query, where, getDoc, writeBatch, serverTimestamp } from "https://www.gstatic.com/firebasejs/11.10.0/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyDgm3K6AuUFMZLc7EZnQW7pKI7zDGyA43c",
  authDomain: "nexo-360-9ed4c.firebaseapp.com",
  projectId: "nexo-360-9ed4c",
  storageBucket: "nexo-360-9ed4c.firebasestorage.app",
  messagingSenderId: "9819698541",
  appId: "1:9819698541:web:97bd81caeab00b22409664",
  measurementId: "G-ZZQ3MDFSJ8"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const state = { events: [], type: "all", search: "" };
const $ = (id) => document.getElementById(id);
const esc = (value = "") => String(value).replace(/[&<>'"]/g, (char) => ({"&":"&amp;","<":"&lt;",">":"&gt;","'":"&#39;",'"':"&quot;"}[char]));
const dateOf = (value) => value?.toDate ? value.toDate() : value instanceof Date ? value : new Date(0);
const formatDate = (value) => new Intl.DateTimeFormat("es-GT", { dateStyle: "long", timeStyle: "short" }).format(dateOf(value));
const month = (value) => new Intl.DateTimeFormat("es-GT", { month: "short" }).format(dateOf(value)).replace(".", "");

$("year").textContent = new Date().getFullYear();
$("menu").addEventListener("click", () => $("nav").classList.toggle("open"));
$("search").addEventListener("input", (event) => { state.search = event.target.value.toLowerCase(); renderEvents(); });
document.querySelectorAll(".tab").forEach((button) => button.addEventListener("click", () => {
  document.querySelectorAll(".tab").forEach((tab) => tab.classList.remove("active"));
  button.classList.add("active"); state.type = button.dataset.type; renderEvents();
}));
$("dialog-close").addEventListener("click", () => $("event-dialog").close());

onSnapshot(query(collection(db, "events"), where("isPublic", "==", true)), (snapshot) => {
  state.events = snapshot.docs.map((item) => ({ id: item.id, ...item.data() })).sort((a,b) => dateOf(a.date)-dateOf(b.date));
  $("connection").textContent = "✓ Conectado con Firebase"; $("connection").className = "connection ok";
  renderEvents(); fillEventSelect();
}, (error) => {
  $("connection").textContent = `No se pudo leer Firebase: ${error.message}`; $("connection").className = "connection error";
  $("events").innerHTML = "<p>No fue posible cargar los eventos. Revisa la configuración y las reglas.</p>";
});

function filteredEvents(){return state.events.filter((event)=>{
  const type = event.eventType === "youth" ? "youth" : "school";
  const haystack = `${event.name||""} ${event.location||""} ${event.description||""} ${event.area||""} ${event.category||""}`.toLowerCase();
  return (state.type === "all" || state.type === type) && haystack.includes(state.search);
});}

function renderEvents(){
  const events = filteredEvents();
  $("events").innerHTML = events.length ? events.map((event)=>{
    const date = dateOf(event.date); const youth = event.eventType === "youth"; const open = event.registrationOpen && event.status === "active";
    return `<article class="event-card"><div class="event-art ${youth?'youth-art':''}"><div class="date-badge"><b>${date.getDate()}</b><span>${esc(month(date))}</span></div><span class="type">${youth?'Movimiento Juventud':'Evento escolar'}</span></div><div class="event-body"><h3>${esc(event.name)}</h3><p>${esc(event.description)}</p><div class="meta"><span>📅 ${esc(formatDate(event.date))}</span><span>📍 ${esc(event.location)}</span><span>🏷 ${esc(event.area||'General')} · ${esc(event.category||'General')}</span></div><div class="event-footer"><span class="pill ${open?'':'closed'}">${open?'Inscripción abierta':'Inscripción cerrada'}</span><button class="link-button" data-event="${esc(event.id)}">Detalles →</button></div></div></article>`;
  }).join("") : "<p>No hay eventos que coincidan con la búsqueda.</p>";
  document.querySelectorAll("[data-event]").forEach((button)=>button.addEventListener("click",()=>openEvent(button.dataset.event)));
}

function openEvent(id){
  const event = state.events.find((item)=>item.id===id); if(!event)return;
  $("dialog-content").innerHTML = `<span class="eyebrow dark">${event.eventType==='youth'?'Movimiento Juventud':'Evento escolar'}</span><h2>${esc(event.name)}</h2><p>${esc(event.description)}</p><dl><div><dt>Fecha</dt><dd>${esc(formatDate(event.date))}</dd></div><div><dt>Ubicación</dt><dd>${esc(event.location)}</dd></div><div><dt>Área</dt><dd>${esc(event.area||'General')}</dd></div><div><dt>Categoría</dt><dd>${esc(event.category||'General')}</dd></div><div><dt>Capacidad</dt><dd>${esc(event.capacity||'Por confirmar')}</dd></div></dl>${event.regulationLink?`<p><a href="${esc(event.regulationLink)}" target="_blank" rel="noopener">Abrir reglamento</a></p>`:""}`;
  $("event-dialog").showModal();
}

function fillEventSelect(){
  const select=$("event-select"); const current=select.value;
  select.innerHTML='<option value="">Selecciona un evento</option>'+state.events.filter((event)=>event.registrationOpen&&event.status==='active').map((event)=>`<option value="${esc(event.id)}">${esc(event.name)} — ${esc(formatDate(event.date))}</option>`).join('');
  if([...select.options].some((option)=>option.value===current))select.value=current;
}

onSnapshot(collection(db,"event_live_locations"),(snapshot)=>{
  const points=snapshot.docs.map((item)=>({id:item.id,...item.data()})).sort((a,b)=>(a.pointNumber||0)-(b.pointNumber||0));
  $("markers").innerHTML=points.map((point)=>`<button class="marker ${esc(point.status||'finished')}" style="left:${Math.max(2,Math.min(98,Number(point.xPercent)||50))}%;top:${Math.max(2,Math.min(98,Number(point.yPercent)||50))}%" title="${esc(point.eventName||point.locationName||'Punto')}">${esc(point.pointNumber||'')}</button>`).join('');
  $("map-list").innerHTML=points.length?points.map((point)=>`<div class="map-item"><b>${esc(point.pointNumber)}. ${esc(point.locationName||'Ubicación')}</b><span>${esc(point.eventName||'Sin actividad')}</span><small>${esc(point.status||'')}</small></div>`).join(''):'<p>No hay ubicaciones registradas.</p>';
});

onSnapshot(collection(db,"event_announcements"),(snapshot)=>renderSimple("announcements",snapshot.docs,"No hay avisos públicos."));
onSnapshot(collection(db,"event_gallery_items"),(snapshot)=>renderSimple("gallery",snapshot.docs,"No hay recursos publicados."));
function renderSimple(target,docs,empty){
  $(target).innerHTML=docs.length?docs.map((item)=>{const data=item.data();return `<article class="info-card"><h4>${esc(data.title||'Publicación')}</h4><p>${esc(data.message||data.description||'')}</p>${data.linkUrl?`<a href="${esc(data.linkUrl)}" target="_blank" rel="noopener">Abrir recurso →</a>`:''}</article>`;}).join(''):`<p>${empty}</p>`;
}

$("registration-form").addEventListener("submit",async(event)=>{
  event.preventDefault(); const button=$("submit"); const status=$("form-status");
  if(!$("consent").checked){status.textContent="Debes aceptar la autorización.";return;}
  const eventId=$("event-select").value; const selected=state.events.find((item)=>item.id===eventId);
  if(!selected){status.textContent="Selecciona un evento válido.";return;}
  button.disabled=true;status.textContent="Guardando…";
  try{
    const requestRef=doc(collection(db,"event_registration_requests"));
    const publicRef=doc(db,"public_registration_status",requestRef.id);
    const batch=writeBatch(db);
    batch.set(requestRef,{
      eventId:eventId,eventName:selected.name||"",fullName:$("full-name").value.trim(),email:$("email").value.trim().toLowerCase(),phone:$("phone").value.trim(),organization:$("organization").value.trim(),area:$("area").value.trim(),category:$("category").value.trim(),trackingCode:requestRef.id,authorizationFileUrl:null,status:"pending",checkedIn:false,createdAt:serverTimestamp(),updatedAt:serverTimestamp()
    });
    batch.set(publicRef,{eventId:eventId,eventName:selected.name||"",status:"pending",checkedIn:false,publicComment:"Solicitud recibida y pendiente de revisión.",updatedAt:serverTimestamp()});
    await batch.commit();
    status.innerHTML=`Solicitud enviada. Guarda tu código: <b>${esc(requestRef.id)}</b>`;
    event.target.reset(); fillEventSelect();
  }catch(error){status.textContent=`No se pudo enviar: ${error.message}`;}finally{button.disabled=false;}
});

$("status-form").addEventListener("submit",async(event)=>{
  event.preventDefault(); const code=$("tracking").value.trim(); const result=$("status-result"); result.textContent="Consultando…";
  try{
    const snapshot=await getDoc(doc(db,"public_registration_status",code));
    if(!snapshot.exists()){result.innerHTML='<div class="status-card rejected">No existe una solicitud con ese código.</div>';return;}
    const data=snapshot.data();
    result.innerHTML=`<div class="status-card ${esc(data.status)}"><b>${esc(statusLabel(data.status))}</b><p>${esc(data.eventName||'Evento')}</p><p>${esc(data.publicComment||'')}</p><small>${data.checkedIn?'Llegada registrada':'Llegada no registrada'}</small></div>`;
  }catch(error){result.textContent=`No fue posible consultar: ${error.message}`;}
});
function statusLabel(status){return({pending:'Pendiente',approved:'Aprobada',reserved:'En reserva',rejected:'Rechazada'})[status]||status;}
