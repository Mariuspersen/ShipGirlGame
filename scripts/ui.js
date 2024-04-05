function create_button(parent,callback,text,h) {
    const button = document.createElement("button");
    button.innerText = text;
    button.className = "ui-button";
    button.style = `height: ${h}px;`

    button.addEventListener('click',e => {
        callback()
    });
    parent?.appendChild(button);
}

function create_dropdown(parent,buttons,text,x,y,w,h) {
    const div = document.createElement("div")

    const label = document.createElement("label")
    label.className = "ui-titlebar"
    label.innerText = text;

    div.appendChild(label)

    const btn_h = h / buttons.length;

    div.style = `position: absolute; top: ${y-(h/2)}px; left: ${x-(w/2)}px; width: ${w}px; height: ${h}px`;
    div.className = "ui-menu";
    buttons.forEach((button,i) => {
        create_button(div,button.callback,button.text,btn_h)
    });
    div.addEventListener('mouseout', e => {
        if (e.toElement.parentNode === div) {
            return
        }
        if(e.target === div) {
            e.target.remove()
        }
    })
    parent?.appendChild(div)
}

Element.prototype.remove = function () {
    this.parentElement.removeChild(this);
}

NodeList.prototype.remove = HTMLCollection.prototype.remove = function () {
    for (let i = this.length - 1; i >= 0; i--) {
        if (this[i] && this[i].parentElement) {
            this[i].parentElement.removeChild(this[i]);
        }
    }
}