function create_button(parent,text,x,y,w,h) {
    const button = document.createElement("button");
    button.style = `position: absolute; top: ${y}px; left: ${x}px; width: ${w}px; height: ${h}px`;
    button.innerText = text;
    button.className = "ui";
    parent?.appendChild(button);
}