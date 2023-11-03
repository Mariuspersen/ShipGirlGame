window.addEventListener('resize', window_resize);
window.addEventListener('contextmenu', context_menu)

function window_resize(e) {
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
}

function context_menu(e) {
    e.preventDefault()
    console.log(e)
    create_button(mainbody,"Hello there",e.clientX,e.clientY,300,75)
    return false
}



