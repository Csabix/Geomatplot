- [x] Átírni hogy id-ban legyen a neve az objektumnak
- [x] Moveable objektumok utsónak legyenek rajzolva
- [x] Drag
- [ ] callbackek (késöbb több pont lesz ez)
    1. seg1 (háromszöges példa) interaktív (hogyan csináljak mátrixokat, azok elemeit hogyan rendeljem aztán dolgokhoz)

## script save
```
<script type="text/javascript"><![CDATA[

<!-- --------------------------------------------------------------------- -->

const A = document.getElementById("A");
console.log(A);

A.addEventListener("mouseover", () => {
    A.setAttribute("class", "hover draggable");
})

A.addEventListener("mouseleave", () => {
    A.setAttribute("class", "");
})

<!-- --------------------------------------------------------------------- -->
const B = document.getElementById("B");

B.addEventListener("mouseover", () => {
    B.setAttribute("class", "hover draggable");
})

B.addEventListener("mouseleave", () => {
    B.setAttribute("class", "");
})

<!-- --------------------------------------------------------------------- -->
const C = document.getElementById("C");

C.addEventListener("mouseover", () => {
    C.setAttribute("class", "hover draggable");
})

C.addEventListener("mouseleave", () => {
    C.setAttribute("class", "");
})

<!-- --------------------------------------------------------------------- -->


function makeDraggable(evt) {
    var svg = evt.target;
    svg.addEventListener('mousedown', startDrag);
    svg.addEventListener('mousemove', drag);
    svg.addEventListener('mouseup', endDrag);
    svg.addEventListener('mouseleave', endDrag);

    let selectedElement;

    function startDrag(evt) {
        if (evt.target.classList.contains('draggable')) {
            selectedElement = evt.target;
            offset = getMousePosition(evt);
            offset.x -= parseFloat(selectedElement.getAttributeNS(null, "cx"));
            offset.y -= parseFloat(selectedElement.getAttributeNS(null, "cy"));
        }
    }
    function drag(evt) {
        if (selectedElement) {
            evt.preventDefault();
            var coord = getMousePosition(evt);
            selectedElement.setAttributeNS(null, "cx", coord.x - offset.x);
            selectedElement.setAttributeNS(null, "cy", coord.y - offset.y);
        }
    }
    function endDrag(evt) {
        selectedElement = null;
    }

    function getMousePosition(evt) {
    let CTM = svg.getScreenCTM();
    return {
        x: (evt.clientX - CTM.e) / CTM.a,
        y: (evt.clientY - CTM.f) / CTM.d
    };
}
}



]]></script>
```