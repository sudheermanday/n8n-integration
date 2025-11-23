/**
 * Boilerplate code generator for common feature types
 * Can be triggered by n8n workflows or run standalone
 */

const fs = require('fs');
const path = require('path');

const FEATURE_TYPES = {
  api: {
    files: [
      {
        path: 'src/routes/{name}.js',
        template: `// {ticket_id}: {name}
const express = require('express');
const router = express.Router();
const {name}Controller = require('../controllers/{name}Controller');

// GET /api/{name}
router.get('/', {name}Controller.getAll);

// GET /api/{name}/:id
router.get('/:id', {name}Controller.getById);

// POST /api/{name}
router.post('/', {name}Controller.create);

// PUT /api/{name}/:id
router.put('/:id', {name}Controller.update);

// DELETE /api/{name}/:id
router.delete('/:id', {name}Controller.delete);

module.exports = router;
`
      },
      {
        path: 'src/controllers/{name}Controller.js',
        template: `// {ticket_id}: {name} Controller
const {name}Service = require('../services/{name}Service');

exports.getAll = async (req, res) => {
  try {
    const data = await {name}Service.getAll();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    const data = await {name}Service.getById(id);
    if (!data) {
      return res.status(404).json({ error: 'Not found' });
    }
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.create = async (req, res) => {
  try {
    const data = await {name}Service.create(req.body);
    res.status(201).json(data);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const data = await {name}Service.update(id, req.body);
    res.json(data);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    await {name}Service.delete(id);
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
`
      },
      {
        path: 'src/services/{name}Service.js',
        template: `// {ticket_id}: {name} Service
const {name}Repository = require('../repositories/{name}Repository');

class {Name}Service {
  async getAll() {
    return await {name}Repository.findAll();
  }

  async getById(id) {
    return await {name}Repository.findById(id);
  }

  async create(data) {
    // Add validation logic here
    return await {name}Repository.create(data);
  }

  async update(id, data) {
    return await {name}Repository.update(id, data);
  }

  async delete(id) {
    return await {name}Repository.delete(id);
  }
}

module.exports = new {Name}Service();
`
      },
      {
        path: 'tests/{name}.test.js',
        template: `// {ticket_id}: {name} Tests
const request = require('supertest');
const app = require('../src/app');

describe('{Name} API', () => {
  describe('GET /api/{name}', () => {
    it('should return all {name}', async () => {
      const response = await request(app)
        .get('/api/{name}')
        .expect(200);
      
      expect(Array.isArray(response.body)).toBe(true);
    });
  });

  describe('GET /api/{name}/:id', () => {
    it('should return a single {name}', async () => {
      const response = await request(app)
        .get('/api/{name}/1')
        .expect(200);
      
      expect(response.body).toHaveProperty('id');
    });
  });

  describe('POST /api/{name}', () => {
    it('should create a new {name}', async () => {
      const newItem = {
        // Add required fields here
      };
      
      const response = await request(app)
        .post('/api/{name}')
        .send(newItem)
        .expect(201);
      
      expect(response.body).toMatchObject(newItem);
    });
  });
});
`
      }
    ]
  },
  ui: {
    files: [
      {
        path: 'src/components/{Name}/{Name}.jsx',
        template: `// {ticket_id}: {Name} Component
import React, { useState, useEffect } from 'react';
import './{Name}.css';

const {Name} = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState(null);

  useEffect(() => {
    // Fetch data on component mount
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch data logic here
      // const response = await api.get('/api/{name}');
      // setData(response.data);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="{name}">
      <h2>{Name}</h2>
      {/* Component content here */}
    </div>
  );
};

export default {Name};
`
      },
      {
        path: 'src/components/{Name}/{Name}.css',
        template: `.{name} {
  /* Component styles here */
}

.{name} h2 {
  /* Heading styles */
}
`
      },
      {
        path: 'src/components/{Name}/index.js',
        template: `export { default } from './{Name}';
`
      },
      {
        path: 'src/components/{Name}/{Name}.test.jsx',
        template: `// {ticket_id}: {Name} Tests
import React from 'react';
import { render, screen } from '@testing-library/react';
import {Name} from './{Name}';

describe('{Name} Component', () => {
  it('should render correctly', () => {
    render(<{Name} />);
    expect(screen.getByText('{Name}')).toBeInTheDocument();
  });
});
`
      }
    ]
  }
};

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function generateFiles(featureType, featureName, ticketId, outputDir = './output') {
  const config = FEATURE_TYPES[featureType];
  
  if (!config) {
    throw new Error(`Unknown feature type: ${featureType}. Available types: ${Object.keys(FEATURE_TYPES).join(', ')}`);
  }

  const name = featureName.toLowerCase();
  const Name = capitalize(name);
  const replacements = {
    '{name}': name,
    '{Name}': Name,
    '{ticket_id}': ticketId
  };

  // Create output directory
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  config.files.forEach(fileConfig => {
    let filePath = fileConfig.path;
    let content = fileConfig.template;

    // Replace placeholders
    Object.keys(replacements).forEach(placeholder => {
      filePath = filePath.replace(placeholder, replacements[placeholder]);
      content = content.replace(new RegExp(placeholder, 'g'), replacements[placeholder]);
    });

    const fullPath = path.join(outputDir, filePath);
    const dir = path.dirname(fullPath);

    // Create directory if it doesn't exist
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    // Write file
    fs.writeFileSync(fullPath, content);
    console.log(`✅ Created: ${fullPath}`);
  });

  console.log(`\n✨ Generated ${config.files.length} files for ${featureType} feature: ${featureName}`);
}

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 3) {
    console.log('Usage: node generate-boilerplate.js <type> <name> <ticket-id> [output-dir]');
    console.log('\nExample:');
    console.log('  node generate-boilerplate.js api user-management PROJ-123');
    console.log('  node generate-boilerplate.js ui login-form PROJ-456 ./src');
    console.log('\nAvailable types:', Object.keys(FEATURE_TYPES).join(', '));
    process.exit(1);
  }

  const [type, name, ticketId, outputDir] = args;
  
  try {
    generateFiles(type, name, ticketId, outputDir);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

module.exports = { generateFiles, FEATURE_TYPES };

