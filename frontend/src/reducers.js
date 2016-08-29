'use strict';

// reducer
export const chat = (state={}, action) => {
    switch(action.type) {
        case 'action_1':
            return {...state, data: action.data};
        //case 'action_2':
        //    return {...state, ***};
        //    break;
        //
        //case: 'TIMER':
        //    return {...state, time: new Date().toLocaleTimeString()};
        //    break;

        default:
            return state;
    }
};
