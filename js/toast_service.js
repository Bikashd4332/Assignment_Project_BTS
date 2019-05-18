/**
 This is the constructor for the ToastMaker object. Which
 * generates alert boxes on the document to alert an error.
 * @constructor
 * @param {Number} duration - A number represening how milisecond long the popup
 * should display.
 * @param {HTMLDivElement} toastParentElement - The parent div element where
 * the generated toast should be placed inside.
 */
function ToastMaker(duration, toastParentElement) {
    if (duration != undefined) {
      this.__proto__.duration = duration;
    }
  
    if (toastParentElement != undefined) {
      this.__proto__.toastParentElement = toastParentElement;
    }
  }
  
  ToastMaker.prototype.duration = 3000;
  ToastMaker.prototype.toastParentElement = null;
  ToastMaker.prototype.count = 0;
  
  /**
   * @desc This function sets the parent div element for toast
   * where toasts are places inside.
   * @param {HTMLDivElement} toastParentElement
   */
  ToastMaker.prototype.setToastParentElement = function(toastParentElement) {
    this.__proto__.toastParentElement = toastParentElement;
  };
  
  ToastMaker.prototype.show = function( content = 'Toast message goes here.' ) {
    const toastBodyDiv = document.createElement( 'div' );
    const toastDiv = document.createElement('div');
    const toastIconDiv = document.createElement( 'div' );
    const toastIcon = document.createElement( 'i' );
    const contentSpan = document.createElement( 'span' );
  
    toastDiv.classList.add( 'toast' );
    toastBodyDiv.classList.add( 'toast-body' );
    toastIcon.classList.add( 'fa', 'fa-exclamation-circle' );
    toastIconDiv.classList.add( 'toast-icon' );
    contentSpan.classList.add( 'toast-message' );
  
    toastBodyDiv.appendChild( toastIconDiv );
    contentSpan.innerText = content;
    toastBodyDiv.appendChild( contentSpan );
    toastIconDiv.appendChild( toastIcon );
    this.__proto__.count++;
  
    toastDiv.appendChild( toastBodyDiv );
  
    toastDiv.style.top = `${this.__proto__.count * 51}px`;
    toastDiv.classList.add( 'animate-in' );
  
    this.__proto__.toastParentElement.appendChild( toastDiv );
  
    setTimeout(() => {
      toastDiv.classList.add( 'animate-out' );
      setTimeout(() => {
        this.__proto__.toastParentElement.removeChild( toastDiv );
        this.__proto__.count--;
  
        const currentShowingToast = document.querySelectorAll( '.toast' );
        currentShowingToast.forEach(( toastDiv ) => {
          toastDiv.style.top = `${parseInt( toastDiv.style.top, 10 ) - 51}px`;
        });
      }, 300);
    }, this.__proto__.duration);
  };