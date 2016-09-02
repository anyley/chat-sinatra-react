'use strict';

import { v4 } from 'node-uuid'


export const serverHello = (filter) => {
  return {
    type: 'SET_VISIBILITY_FILTER',
    filter
  }
}
