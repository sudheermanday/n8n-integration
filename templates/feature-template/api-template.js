/**
 * API Feature Template
 * This template is used by the feature automation workflow
 * to generate boilerplate code for new API features
 */

// Replace placeholders:
// {name} - lowercase feature name
// {Name} - capitalized feature name
// {ticket_id} - ticket/issue ID

// Routes file template
const routesTemplate = `
// {ticket_id}: {name}
const express = require('express');
const router = express.Router();
const {name}Controller = require('../controllers/{name}Controller');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { {name}Schema } = require('../schemas/{name}Schema');

router.get('/', authenticate, {name}Controller.getAll);
router.get('/:id', authenticate, {name}Controller.getById);
router.post('/', authenticate, validate({name}Schema), {name}Controller.create);
router.put('/:id', authenticate, validate({name}Schema), {name}Controller.update);
router.delete('/:id', authenticate, {name}Controller.delete);

module.exports = router;
`;

// Controller template
const controllerTemplate = `
// {ticket_id}: {name} Controller
const {name}Service = require('../services/{name}Service');
const { handleError } = require('../utils/errorHandler');

exports.getAll = async (req, res) => {
  try {
    const { page = 1, limit = 10, ...filters } = req.query;
    const data = await {name}Service.getAll({ page, limit, filters });
    res.json({
      success: true,
      data,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit)
      }
    });
  } catch (error) {
    handleError(res, error);
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    const data = await {name}Service.getById(id);
    if (!data) {
      return res.status(404).json({
        success: false,
        message: '{Name} not found'
      });
    }
    res.json({ success: true, data });
  } catch (error) {
    handleError(res, error);
  }
};

exports.create = async (req, res) => {
  try {
    const data = await {name}Service.create(req.body);
    res.status(201).json({
      success: true,
      data,
      message: '{Name} created successfully'
    });
  } catch (error) {
    handleError(res, error);
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const data = await {name}Service.update(id, req.body);
    res.json({
      success: true,
      data,
      message: '{Name} updated successfully'
    });
  } catch (error) {
    handleError(res, error);
  }
};

exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    await {name}Service.delete(id);
    res.status(204).send();
  } catch (error) {
    handleError(res, error);
  }
};
`;

module.exports = {
  routesTemplate,
  controllerTemplate
};

