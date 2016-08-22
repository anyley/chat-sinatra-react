'use strict';

// reducer
export const counter = (state={}, action) => {
    switch(action.type) {
        case 'action_1':
            return {...state, data: action.data};
            break;
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
