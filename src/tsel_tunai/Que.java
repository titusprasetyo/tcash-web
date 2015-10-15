package tsel_tunai;
import java.util.*;

public class Que {

  int size = 0;
  int max_size = 100000;
  int wait_time = 30000;
  private final LinkedList queue;

  public Que() {

    queue = new LinkedList();

  }

  public void setWaitTime(int i){
      this.wait_time = i;
  }

  public void setMax(int i){
      this.max_size = i;
  }

  public int getSize() {

    return queue.size();

  }


  public boolean add2(Object o) {
    boolean b = true;
    synchronized(queue) {
      if(this.getSize() <= this.max_size) {
          queue.addLast(o);
          queue.notify();
      }else b = false;
    }

    return b;

  }

  public boolean add(Object o) {

   synchronized(queue) {
     queue.addLast(o);
     queue.notify();

   }

   return true;

 }



 public boolean addF(Object o) {

   synchronized(queue) {
     queue.addFirst(o);
     queue.notify();

   }

   return true;

 }







 public Object get2() {

     Object o = null;

     synchronized(queue) {
       if(this.getSize() == 0) {

           try{ queue.wait(this.wait_time); } catch(Exception ee) {}

       } else
       o = queue.removeFirst();
     }

     return o;

  }



  public Object get() {

    Object o = null;

    synchronized(queue) {
      while(queue.isEmpty()) {
          try{ queue.wait(); } catch(Exception ee) {}
      }
      o = queue.removeFirst();
    }

    return o;

  }


  public void wait2(){
      synchronized(queue) {
        while(queue.isEmpty()) {
          try{ queue.wait(); } catch(Exception ee) {}
        }
      }
  }



}
