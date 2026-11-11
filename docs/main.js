function abrirModal(elemento) {
    var modal = document.querySelector(".imgdiv");
    var imagenZoom = document.querySelector(".imgzoom");
    modal.style.display = "flex";
    imagenZoom.src = elemento.src;
}
function cerrarModal() {
    document.querySelector(".imgdiv").style.display = "none";
}

// ---------- Tabla de puntajes (Top 10) ----------
// URL de Google Apps Script
var RANKING_URL = "https://script.google.com/macros/s/AKfycbwnq2ODIsn6Ad-OFHA6aNU4WH0uwRETFRouhSIH6Ji7XpexedWl9MVomTkgU3zpA0nWVw/exec";

function formatearTiempo(seg) {
    var m = Math.floor(seg / 60);
    var s = (seg - m * 60).toFixed(2);
    if (s.length < 5) s = "0" + s;
    return m + ":" + s;
}

function actualizarRanking() {
    var estado = document.getElementById("ranking-estado");
    estado.textContent = "Actualizando puntajes...";
    
    fetch(RANKING_URL + "?t=" + Date.now())
        .then(function (r) { return r.text(); })
        .then(function (txt) {
            try { return JSON.parse(txt); }
            catch (e) { throw new Error("la URL no devolvió JSON (acceso restringido o mal publicada)"); }
        })
        .then(function (data) {
            if (data.status !== "success") throw new Error("respuesta inválida");
            var tbody = document.getElementById("ranking-filas");
            tbody.textContent = "";
            if (data.top.length === 0) {
                var vacia = tbody.insertRow();
                var celda = vacia.insertCell();
                celda.colSpan = 5;
                celda.textContent = "Todavía no hay puntajes.";
            }
            
            // Limitamos estrictamente a las primeras 10 entradas (Top 10)
            var top10Data = data.top.slice(0, 10);
            
            top10Data.forEach(function (p, i) {
                var fila = tbody.insertRow();
                fila.insertCell().textContent = i + 1;
                fila.insertCell().textContent = p.nombre;
                fila.insertCell().textContent = p.fecha || "";
                fila.insertCell().textContent = p.hora || "";
                var t = fila.insertCell();
                t.textContent = formatearTiempo(p.tiempo);
                t.className = "ranking-time";
            });
            
            var ahora = new Date().toLocaleTimeString();
            estado.textContent = "Última actualización manual: " + ahora;
        })
        .catch(function (err) {
            console.error("Ranking:", err);
            estado.textContent = "Error: " + (err && err.message ? err.message : err) + " — reintentando…";
        });
}

// Carga inicial únicamente al abrir o recargar la página (se eliminó setInterval)
actualizarRanking();
