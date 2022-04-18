import { elementToXPath } from 'stimulus_reflex/javascript/utils'
import ApplicationController from './application_controller'

/* This is the custom StimulusReflex controller for the Example Reflex.
 * Learn more at: https://docs.stimulusreflex.com
 */
export default class extends ApplicationController {
  /*
   * Regular Stimulus lifecycle methods
   * Learn more at: https://stimulusjs.org/reference/lifecycle-callbacks
   *
   * If you intend to use this controller as a regular stimulus controller as well,
   * make sure any Stimulus lifecycle methods overridden in ApplicationController call super.
   *
   * Important:
   * By default, StimulusReflex overrides the -connect- method so make sure you
   * call super if you intend to do anything else when this controller connects.
  */

  connect () {
    super.connect()
    // add your code here, if applicable

  }


  /* Reflex specific lifecycle methods.
   *
   * For every method defined in your Reflex class, a matching set of lifecycle methods become available
   * in this javascript controller. These are optional, so feel free to delete these stubs if you don't
   * need them.
   *
   * Important:
   * Make sure to add data-controller="example" to your markup alongside
   * data-reflex="Example#dance" for the lifecycle methods to fire properly.
   *
   * Example:
   *
   *   <a href="#" data-reflex="click->Example#dance" data-controller="example">Dance!</a>
   *
   * Arguments:
   *
   *   element - the element that triggered the reflex
   *             may be different than the Stimulus controller's this.element
   *
   *   reflex - the name of the reflex e.g. "Example#dance"
   *
   *   error/noop - the error message (for reflexError), otherwise null
   *
   *   reflexId - a UUID4 or developer-provided unique identifier for each Reflex
   */

  // Assuming you create a "Example#dance" action in your Reflex class
  // you'll be able to use the following lifecycle methods:


  
  beforeToggle (element, reflex, noop, reflexId) {

    // // Set up references for later use
    // this.taskText = this.element.parentElement.previousElementSibling
    // const stimObj = this

    // // Add the appropriate animation
    // if (this.taskText.classList.contains('completed')){
    //   this.taskText.classList.add('remove-strikethru')
    //   this.taskText.classList.remove('completed')
    // } else {
    //   this.taskText.classList.add('strikethru')
    // }
    
    // // Fire off database change when animation ended
    // this.updateTask = function(){
    //   stimObj.stimulate('example#test')
    // }
    // this.taskText.addEventListener("animationend", this.updateTask)


  }

  // afterToggle (element, reflex, noop, reflexId){
  // }

  // beforeDance(element, reflex, noop, reflexId) {
  //  element.innerText = 'Putting dance shoes on...'
  // }


  // danceSuccess(element, reflex, noop, reflexId) {
  //   element.innerText = '\nDanced like no one was watching! Was someone watching?'
  // }

  // danceError(element, reflex, error, reflexId) {
  //   console.error('danceError', error);
  //   element.innerText = "\nCouldn\'t dance!"
  // }

  // afterDance(element, reflex, noop, reflexId) {
  //   element.innerText = '\nWhatever that was, it\'s over now.'
  // }

  // finalizeToggle(element, reflex, noop, reflexId) {
  //   taskText.removeEventListener("animationend", update)
  // }
  finalizeTest(element, reflex, noop, reflexId) {
    // // Remove event listener to avoid duplicates
    // this.taskText.removeEventListener("animationend", this.updateTask)
  }
}
