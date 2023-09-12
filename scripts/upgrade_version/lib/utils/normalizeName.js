"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var change_case_1 = require("change-case");
var dartKeywords_1 = __importDefault(require("./dartKeywords"));
function normalizeName(value) {
    var name = (0, change_case_1.snakeCase)(value);
    if (dartKeywords_1.default.includes(name)) {
        name = name + '_';
    }
    if (name.charAt(0) >= '0' && name.charAt(0) <= '9') {
        return '$' + name;
    }
    return name;
}
exports.default = normalizeName;
