ArrayList<Event> events;
StringList eventCodes;

///MAP///
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.StamenMapProvider;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;

UnfoldingMap map;

///MAP///

//on the 35th second the camera starts to move
float time = 35;

void setup()
{
  size(800, 600, P2D);

  ///MAP///
  map = new UnfoldingMap(this, new StamenMapProvider.Toner());
  map.zoomAndPanTo(new Location(51.513, -0.133), 16);
  MapUtils.createDefaultEventDispatcher(this, map);
  ///MAP///

  loadData();
  frameRate(460);
  background(255);

  ////loading event codes
  int ind;
  String [] evdata = loadStrings("eventCodes.csv");
  eventCodes= new StringList();
  for (int i=2; i<evdata.length; i++)
  {
    String [] thisRow2 = split(evdata[i], ';');
    ind=int(thisRow2[0]);
    eventCodes.set(ind, thisRow2[1]);
    eventCodes.set(0, "No Event");
    eventCodes.set(1, "start of a junction event, Detour (look 20)");
  }
  //loading complete
  //println(eventCodes);
}

void draw()
{
  ///MAP/// 
  map.draw();

  ///MAP///

  //helps us have the fade out effect
  fill(255, 1);
  rect(0, 0, width, height);
  noStroke();


  //this is where the interpolation happens
  //we're storing the previous row and the current row of data
  //into two new array lists that we have named Event
  int currentIndex = getPreviousIndex();
  Event e0 = events.get(currentIndex);
  Event e1 = events.get(currentIndex+1);
  //here it finds the "point in between" the two seconds
  //while the time augments little by little, so do the points/coordinates
  float x = map(time, e0.t, e1.t, e0.x, e1.x);
  float y = map(time, e0.t, e1.t, e0.y, e1.y);
 // float pd = map(time, e0.t, e1.t, e0.code, e1.code);
  float gx, gy;

  //plotting the goals
  if (e1.goaly!=e0.goaly) 
  {
    gx=e1.goalx;
    gy=e1.goaly;
  }
  else
  {
    gx=e0.goalx;
    gy=e0.goaly;
  }
  Location goalLocation = new Location(gy, gx); 
  SimplePointMarker goalmarker= new SimplePointMarker(goalLocation);
  goalmarker.setColor(color(0, 255, 10, 70));
  goalmarker.setStrokeWeight(0);
  map.addMarkers(goalmarker);

  //for adding text to marker (label)
  ScreenPosition posGoal = goalmarker.getScreenPosition(map);
  fill(255, 255, 0, 160);
  rect(posGoal.x-(textWidth("current goal")/2), posGoal.y+0.00013-18, textWidth("current goal"), 8);
  fill(0);
  text("current goal", posGoal.x-(textWidth("current goal")/2), posGoal.y+0.00013-10);
  //marker added
//goals added


  ///route///
  Location sohoLocation = new Location(y-0.00012, x+0.000135); 
  SimplePointMarker sohomarker= new SimplePointMarker(sohoLocation);
  sohomarker.setColor(color(255, 0, 150, 70));
  sohomarker.setStrokeWeight(0);
  map.addMarkers(sohomarker);
  ///route//

//printing event codes
  fill(0);
  String s=eventCodes.get(int(e0.code));
  rect(15, 15, textWidth(s)+30, 60);
  fill(255);
  text("Event", 30, 38);
  text(s, 30, 65);
 //printing event codes

//printing meters walked
//doing the pythagoras
  float hyp;
  hyp=sqrt(sq(e0.east)+sq(e0.north));
  fill(0);
  rect(15, 145, 115, 40); 
  fill(255);
  text("Meters Walked", 30, 165);
  text(hyp, 30, 180);


  //printing the time (and the white rectangle around it
  fill(0);
  rect(15, 90, 100, 40); 
  fill(255);
  text("Timer", 30, 106);
  text(time, 30, 122);

  time+=1.0/60;
}

int getPreviousIndex()
{
  int prevIndex = -1;
  for (int i = 0; i<events.size(); i++)
  {
    if (events.get(i).t>time)
    {  
      prevIndex = i-1;
      //to break edo xrisimopoieitai oste tin proti fora
      //pou ikanopoieitai i sin8iki, na spaei to for loop
      //we're using break, so that the first time the condition
      //is satisfied, the for loop is broken
      //the variable "time" changes for each sixtieth of a second (or something)
      break;
    }
  }
  return prevIndex;
}

void loadData()
{
  String [] sdata = loadStrings("sohodata_firstroute2.csv");
  events = new ArrayList<Event>();
  for (int i = 2; i<sdata.length; i++)
  {
    String [] thisRow = split(sdata[i], ';');
    Event e = new Event();
    e.x = float(thisRow[4]);
    e.y = float(thisRow[5]);
    e.t = float(thisRow[3]);
    e.code = float(thisRow[1]);
    e.goalx=float(thisRow[29]);
    e.goaly=float(thisRow[30]);
    e.east=float(thisRow[57])-762.46515;
    e.north=float(thisRow[58])-323.3659;
    events.add(e);
  }
}




class Event
{
  float t, code, x, y, goalx, goaly, east, north;
}

