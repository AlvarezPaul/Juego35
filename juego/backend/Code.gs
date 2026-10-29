// Pegar en: Planilla de Google > Extensiones > Apps Script
const HOJA = 'puntajes';
const TOP = 5;

function hoja_() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let h = ss.getSheetByName(HOJA);
  if (!h) {
    h = ss.insertSheet(HOJA);
    h.appendRow(['fecha', 'nombre', 'tiempo']);
  }
  return h;
}

function json_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

// Valida y agrega un puntaje a la planilla
function guardar_(nombreCrudo, tiempoCrudo, fechaCruda) {
  const nombre = String(nombreCrudo == null ? '' : nombreCrudo).trim().slice(0, 50);
  const tiempo = Number(tiempoCrudo);
  if (!nombre || !isFinite(tiempo) || tiempo <= 0) {
    return json_({ status: 'error', descartar: true, message: 'Datos inválidos' });
  }

  // Evita que un nombre como "=algo" se ejecute como fórmula en la planilla
  const seguro = /^[=+\-@]/.test(nombre) ? "'" + nombre : nombre;
  const fecha = String(fechaCruda == null || fechaCruda === '' ? new Date().toISOString() : fechaCruda);

  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const h = hoja_();
    // Si el juego reenvía un puntaje que ya llegó (por ejemplo tras un timeout), no lo duplica
    const n = h.getLastRow();
    if (n > 1) {
      const desde = Math.max(2, n - 199);
      const recientes = h.getRange(desde, 2, n - desde + 1, 2).getValues();
      for (let i = 0; i < recientes.length; i++) {
        if (String(recientes[i][0]) === nombre && Math.abs(Number(recientes[i][1]) - tiempo) < 0.000001) {
          return json_({ status: 'success', duplicado: true });
        }
      }
    }
    h.appendRow([fecha, seguro, tiempo]);
  } finally {
    lock.releaseLock();
  }
  return json_({ status: 'success' });
}

// GET ?accion=guardar&nombre=..&tiempo=..&fecha=..  -> el juego guarda un puntaje
// GET (sin parámetros)                              -> la página pide el top 5
function doGet(e) {
  const p = (e && e.parameter) ? e.parameter : {};

  if (p.accion === 'guardar') {
    return guardar_(p.nombre, p.tiempo, p.fecha);
  }

  const h = hoja_();
  const n = h.getLastRow();
  const tz = SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone();
  const filas = n > 1 ? h.getRange(2, 1, n - 1, 3).getValues() : [];
  const top = filas
    .map(function (r) {
      return { fecha: fechaCorta_(r[0], tz), nombre: String(r[1]), tiempo: Number(r[2]) };
    })
    .filter(function (x) { return x.nombre && isFinite(x.tiempo) && x.tiempo > 0; })
    .sort(function (a, b) { return a.tiempo - b.tiempo; })
    .slice(0, TOP);
  return json_({ status: 'success', top: top });
}

// Devuelve la fecha como dd/MM/yyyy (Sheets puede guardarla como fecha real o como texto)
function fechaCorta_(valor, tz) {
  if (valor instanceof Date) {
    return Utilities.formatDate(valor, tz, 'dd/MM/yyyy');
  }
  const m = String(valor).match(/^(\d{4})-(\d{2})-(\d{2})/);
  return m ? m[3] + '/' + m[2] + '/' + m[1] : '';
}

// BORRA TODOS LOS PUNTAJES (deja el encabezado).
// Se ejecuta a mano desde el editor: elegir esta función arriba y tocar "Ejecutar".
// No se puede llamar desde la web ni desde el juego.
function borrarTodosLosPuntajes() {
  const h = hoja_();
  const n = h.getLastRow();
  if (n > 1) h.deleteRows(2, n - 1);
}
