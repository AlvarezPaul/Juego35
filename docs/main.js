function abrirModal(elemento) {
    var modal = document.querySelector(".imgdiv");
    var imagenZoom = document.querySelector(".imgzoom");
    modal.style.display = "flex";
    imagenZoom.src = elemento.src;
}
function cerrarModal() {
    document.querySelector(".imgdiv").style.display = "none";
}

// ---------- Tabla de puntajes (Top 5) ----------
// Pegá acá la URL de tu Apps Script (la que termina en /exec)
var RANKING_URL = "https://script.google.com/macros/s/AKfycbwnq2ODIsn6Ad-OFHA6aNU4WH0uwRETFRouhSIH6Ji7XpexedWl9MVomTkgU3zpA0nWVw/exec";
var RANKING_CADA_SEG = 10;

function formatearTiempo(seg) {
    var m = Math.floor(seg / 60);
    var s = (seg - m * 60).toFixed(2);
    if (s.length < 5) s = "0" + s;
    return m + ":" + s;
}

function actualizarRanking() {
    var estado = document.getElementById("ranking-estado");
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
                celda.colSpan = 4;
                celda.textContent = "Todavía no hay puntajes.";
            }
            data.top.forEach(function (p, i) {
                var fila = tbody.insertRow();
                fila.insertCell().textContent = i + 1;
                fila.insertCell().textContent = p.nombre;
                fila.insertCell().textContent = p.fecha || "";
                var t = fila.insertCell();
                t.textContent = formatearTiempo(p.tiempo);
                t.className = "ranking-time";
            });
            estado.textContent = "Se actualiza solo cada " + RANKING_CADA_SEG + " segundos";
        })
        .catch(function (err) {
            console.error("Ranking:", err);
            estado.textContent = "Error: " + (err && err.message ? err.message : err) + " — reintentando…";
        });
}

actualizarRanking();
setInterval(actualizarRanking, RANKING_CADA_SEG * 1000);
