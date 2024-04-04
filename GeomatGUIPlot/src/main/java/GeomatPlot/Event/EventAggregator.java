package GeomatPlot.Event;

import java.awt.*;
import java.awt.event.MouseWheelEvent;
import java.util.LinkedList;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.awt.event.ComponentEvent.COMPONENT_RESIZED;
import static java.awt.event.MouseEvent.*;
import static java.awt.event.WindowEvent.WINDOW_CLOSING;

public class EventAggregator {
    private List<AWTEvent> singleEventList;
    private List<AWTEvent> duplicatingEventList;
    public EventAggregator() {
        singleEventList = new ArrayList<>(5);
        duplicatingEventList = new LinkedList<>();
    }
    public synchronized Stream<AWTEvent> getEvents() {
        List<AWTEvent> sEvents = singleEventList;
        singleEventList = new ArrayList<>(5);
        List<AWTEvent> dEvents = duplicatingEventList;
        duplicatingEventList = new LinkedList<>();
        return Stream.concat(sEvents.stream(),dEvents.stream());
    }
    public synchronized void addEvent(AWTEvent event) {
        switch (event.getID()){
            case WINDOW_CLOSING:
            case COMPONENT_RESIZED:
            case MOUSE_DRAGGED:
            case MOUSE_RELEASED:
            case MOUSE_PRESSED:
                nonDuplicatingEVT(event);
                break;
            case MOUSE_WHEEL:
                mouseWheelEVT(event);
                break;
            case CreateEvent.CREATE_EVENT:
                CreateEVT((CreateEvent)event);
                break;
            case UpdateEvent.UPDATE_EVENT:
                UpdateEVT((UpdateEvent)event);
                break;
        }
    }
    private void nonDuplicatingEVT(AWTEvent event) {
        if(singleEventList.stream().anyMatch((evt)-> evt.getID() == event.getID())) {
            Stream<AWTEvent> eventStream = singleEventList.stream().filter((evt)-> evt.getID() != event.getID());
            singleEventList = Stream.concat(eventStream,Stream.of(event))
                    .collect(Collectors.toCollection(ArrayList::new));
        } else {
            singleEventList.add(event);
        }
    }
    private void CreateEVT(CreateEvent e) {
        boolean insert = true;
        for (AWTEvent event:singleEventList) {
            if(event.getID() == CreateEvent.CREATE_EVENT &&
            ((CreateEvent)event).type == e.type) {
                insert = false;
                ((CreateEvent)event).merge(e);
                break;
            }
        }
        if(insert) {
            singleEventList.add(e);
        }
    }
    private void UpdateEVT(UpdateEvent e) {
        boolean insert = true;
        for (AWTEvent event:singleEventList) {
            if(event.getID() == UpdateEvent.UPDATE_EVENT &&
                    ((UpdateEvent)event).type == e.type) {
                insert = false;
                ((UpdateEvent)event).merge(e);
                break;
            }
        }
        if(insert) {
            singleEventList.add(e);
        }
    }
    private void mouseWheelEVT(AWTEvent event) {
        if(singleEventList.stream().anyMatch((evt)-> evt.getID() == MOUSE_WHEEL)) {
            singleEventList.stream()
                    .filter((evt) -> evt.getID() == MOUSE_WHEEL)
                    .findFirst()
                    .ifPresent((evt) -> {
                        MouseWheelEvent mEvt = (MouseWheelEvent)evt;
                        evt = new MouseWheelEvent((Component)mEvt.getSource(),mEvt.getID(),
                                0,0,0,0,0,0,0,
                                false,mEvt.getScrollType(),mEvt.getScrollAmount(),
                                mEvt.getWheelRotation()+((MouseWheelEvent)event).getWheelRotation(),
                                mEvt.getPreciseWheelRotation() + ((MouseWheelEvent)event).getPreciseWheelRotation());
                    });
        } else {
            singleEventList.add(event);
        }
    }
    private void addDuplicating(AWTEvent event){
        duplicatingEventList.add(event);
    }
}
