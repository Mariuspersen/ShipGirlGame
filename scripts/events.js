window.addEventListener('resize', window_resize);
window.addEventListener('contextmenu', context_menu)

function window_resize(e) {
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
}

const b = {
    text: "test",
    callback: () => console.log("testing"),

}

const btns = [
    b,
    b,
    b,
]

function context_menu(e) {
    e.preventDefault()
    const collection = [...document.getElementsByClassName('ui-menu')]
    collection.forEach(e => e.remove())
    create_dropdown(mainbody,btns,"haroo",e.clientX,e.clientY,100,300)
    //create_button(mainbody,() => console.log("hello"),"Hello there",e.clientX,e.clientY,300,75)
    return false
}



