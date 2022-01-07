
//prompts

//Create alert dialogs.

// basic
//modbox.alert('Alert Message');


// or
// modbox.alert({
//   body: 'Mensagem alerta'
// });

// Promise
// modbox.alert({
//   body: 'Mensagem Alerta'
// })
// .then(() => console.log('Mensagem resolvida'));

// variants
// modbox.info({
//   // options
// });

// modbox.success({
//   // options
// });

// modbox.danger({
//   // options
// });

// modbox.error({
//   // options
// });



// Create a confirmation dialog.
// modbox.confirm({
//   body: 'Confirmar mensagem',
//   okButton: {
//     label: 'Sim',
//     size: 'lg'
//   },
//   closeButton: {
//     label: 'Não',
//     size: 'sm'
//   }
// })
// .then(() => console.log('Sim button clicked'))
// .catch(() => console.log('Não button clicked'));




// Create a prompt dialog.
// modbox.prompt({
//   body: 'Prompt Dialog',
//   input: {
//     required: true,
//     pattern: /\d+/, // input validation
//   }
// })
// .then(response => console.log(response));



//Create a custom popup box using the modbox method.
// const myModal = new modbox({
//   id: 'myModal',
//   style: 'primary',
//   title: 'My Custom Modal',
//   body: 'Details about that thing you were meant to be doing all day.',
//   justifyButtons: 'between',
//   destroyOnClose: true,
//   buttons: [
//     { label: 'Button 1', style: 'primary' },
//     '<button type="button" class="btn btn-dark" data-bs-dismiss="modal">Button 2</button>'
//   ],
//   events: {
//     shown: () => console.log('modal shown')
//   }
// });
// myModal.addButton({ label: 'Button 3', style: 'danger' }, true);
// myModal.addEvent('hidden', () => console.log('modal hidden'));
// myModal.show();

// const myModal = new modbox({
//     id: 'myModal',
//     style: 'secondary',
//     title: 'My Custom Modal',
//     body: 'Choose your champion:',
//     justifyButtons: 'center',
//     destroyOnClose: true,
//     buttons: [
//         { label: 'Launch', style: 'primary', id: 'yesButton' },
//         { label: 'Cancel', style: 'secondary', id: 'noButton' },
//     ],
// });
// myModal.show();
// document.getElementById('yesButton').onclick = () => { console.log('Mission Launched') };
// document.getElementById('noButton').onclick = () => { console.log('Mission canceled') };

function createCustomModal(id, style, title, body, type, data, email) {
  const myModal = new modbox({
    id: id,
    style: style,
    title: title,
    body: body,
    justifyButtons: 'center',
    destroyOnClose: true,
    buttons: [
      '<button type="button" class="btn btn-game" data-bs-dismiss="modal" id = "yesButton" >Launch</button>',
      { label: 'Cancel', style: 'dark', id: 'noButton' },
    ],
  });
  myModal.show();
  if (type === 'launchMission') {
    //iniciar missao
    document.getElementById('yesButton').onclick = () => missionLaunching(data.idmission, document.getElementById('championChoosen').value, email, data.duration, data.received);
  } else if (type === 'launchTrain') {
    //iniciar treino
    document.getElementById('yesButton').onclick = () => trainLaunching(data.idtrain, document.getElementById('championChoosen').value, email, data.duration, data.received);

  }
}


/*
    //FULL OPTIONS
    // custom icon class
    icon: null,

    // color based on Bootstrap utility classes
    style: 'white',

    // title text color
    titleStyle: null,

    // dialog title
    title: 'Information',

    // dialog content
    body: '',

    // alternate to the body configuration option
    message: '',

    // sm, lg, ...
    size: null,

    // center the popup box
    center: false,

    // enable fade animation
    fade: true,

    // show the popup box on page load
    show: false,

    // set the relatedTarget property on the event object passed to show and shown event callback functions. 
    // can be overridden by passing in an element when calling the .show() method.
    relatedTarget: undefined,

    // is scrollable
    scrollable: true,

    // destroy the popup box on close
    destroyOnClose: false,

    // add default buttons to the popup box
    defaultButton: true,

    // swap button order
    swapButtonOrder: false,

    // start, end, center, between, around, evenly
    justifyButtons: null,

    // events
    events: {
      show: null,
      shown: null,
      hide: null,
      hidden: null,
      hidePrevented: null,
    },

    // only applies to constructor modals
    buttons: [],

    // only applies to class modals, and overwrites defaults set by modbox.defaultButtonOptions
    okButton: {
      label: 'OK',
      style: 'primary'
    },
    closeButton: {
      label: 'Cancel',
      style: 'secondary'
    },

    // only applies to .prompt() class modal
    input: {
      type: 'text',
      class: '',
      value: '',
      title: null,
      placeholder: null,
      autocomplete: 'off',
      minlength: null,
      maxlength: null,
      pattern: null,
      required: false
    },



    //METHODS & PROPERTIES
    // add a new button
    // addButton(options, swapOrder)
    instance.addButton({
      label: 'New Button'
    });

    // dispatch an event
    // addEvent(event, function)
    instance.addEvent('shown', () => console.log('shown'));

    // show the popup box
    instance.show(relatedTarget);

    // hide the popup box
    instance.hide();

    // toggle the popup box
    instance.toggle();

    // dispose the popup box
    instance.dispose();

    // destroy the instance
    instance.destroy();

    // re-position the popup box
    instance.handleUpdate();
    */