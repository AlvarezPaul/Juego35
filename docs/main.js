function abrirModal(elemento) {
    var modal = document.querySelector(".imgdiv");
    var imagenZoom = document.querySelector(".imgzoom");
    modal.style.display = "flex";
    imagenZoom.src = elemento.src;
}
function cerrarModal() {
    document.querySelector(".imgdiv").style.display = "none";
}