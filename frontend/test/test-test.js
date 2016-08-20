import React from 'react';
import { shallow, mount, render } from 'enzyme';
//import Foo from '../src/Foo';

describe("A suite #1", () => {
    it("contains spec with an expectation 0 of 0", () => {
        expect(0).toBe(0);
    });

    it("contains spec with an expectation 1 of 1", () => {
        expect(1).toBe(1);
    });
});

describe("A suite #2", () => {
    it("contains spec with an expectation 3 of 3", () => {
        expect(3).toBe(3);
    });
});