const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const jwt = require('jsonwebtoken');
const pdf = require('html-pdf');
const excel = require('exceljs');
const fileUpload = require('express-fileupload');
const csv = require('csv-parser');
const fs = require('fs');
const unzipper = require('unzipper');

const app = express();
const port = 3000;

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'school_mgt_system',
  password: '12345',
  port: 5432,
});

app.use(bodyParser.json());
app.use(cors());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use(bodyParser.urlencoded({ extended: true }));
const secretKey = 'gautam123';

app.use(fileUpload());

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Fetch fees for a specific class and financial year
app.get('/fees/:classId/:financialYear', async (req, res) => {
  const { classId, financialYear } = req.params;
  try {
    const result = await pool.query('SELECT * FROM fees WHERE class = $1 AND financial_year = $2', [classId, financialYear]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching fees:', err);
    res.status(500).json({ message: 'Failed to fetch fees. Please try again.' });
  }
});

// Fetch fee status for a specific student and financial year
app.get('/feestatus/:student_id', async (req, res) => {
  const { student_id } = req.params;
  const { financialYear } = req.query;

  try {
    const result = await pool.query(`
      SELECT f.quarter, f.class, f.tuition_fee, f.exam_fee, f.sports_fee,
             f.electricity_fee, f.transport_with_bus_fee, f.transport_without_bus_fee,
             f.total_fee, fs.status
      FROM feestatus fs
      JOIN fees f ON fs.fee_id = f.fee_id
      WHERE fs.student_id = $1 AND f.financial_year = $2
    `, [student_id, financialYear]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching fee status:', err);
    res.status(500).json({ message: 'Failed to fetch fee status. Please try again.' });
  }
});

// Fetch student data by ID
app.get('/student/:student_id', async (req, res) => {
  const { student_id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM student WHERE student_id = $1', [student_id]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Student not found' });
    }
  } catch (err) {
    console.error('Error fetching student data:', err);
    res.status(500).json({ message: 'Failed to fetch student data. Please try again.' });
  }
});

// Fetch homework for a specific class
app.get('/homework/:className', async (req, res) => {
  const { className } = req.params;
  try {
    const result = await pool.query('SELECT * FROM homework WHERE class = $1 ORDER BY due_date ASC', [className]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching homework:', err);
    res.status(500).json({ message: 'Failed to fetch homework. Please try again.' });
  }
});

// Mark homework as completed
app.put('/homework/:id/complete', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('UPDATE homework SET status = $1 WHERE id = $2 RETURNING *', ['completed', id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating homework status:', err);
    res.status(500).json({ message: 'Failed to update homework status. Please try again.' });
  }
});

// Fetch fee structure
app.get('/fees', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM fees');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching fees:', err);
    res.status(500).json({ message: 'Failed to fetch fees. Please try again.' });
  }
});

app.post('/fees', async (req, res) => {
  const {
    class: studentClass,
    quarter,
    financialYear,
    tuitionFee,
    examFee,
    sportsFee,
    electricityFee,
    transportWithBusFee,
    transportWithoutBusFee,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO fees (class, quarter, financial_year, tuition_fee, exam_fee, sports_fee, electricity_fee, transport_with_bus_fee, transport_without_bus_fee)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [studentClass, quarter, financialYear, tuitionFee, examFee, sportsFee, electricityFee, transportWithBusFee, transportWithoutBusFee]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding fee:', err);
    res.status(500).json({ message: 'Failed to add fee. Please try again.' });
  }
});

// Helper function to validate integer fields
const isValidInteger = (value) => {
  return Number.isInteger(parseInt(value));
}

app.get('/studentList', async (req, res) => {
  const offset = parseInt(req.query.offset, 10) || 0;
  const limit = parseInt(req.query.limit, 10) || 100;
  const schoolRange = req.query.schoolRange;

  let query = 'SELECT * FROM student_list WHERE class_section ';
  if (schoolRange === '6-8') {
    query += 'IN (\'6A\', \'6B\', \'6C\', \'6D\', \'6E\', \'6F\', \'6G\', \'6H\', ' +
             '\'7A\', \'7B\', \'7C\', \'7D\', \'7E\', \'7F\', \'7G\', \'7H\', ' +
             '\'8A\', \'8B\', \'8C\', \'8D\', \'8E\', \'8F\', \'8G\', \'8H\')';
  } else if (schoolRange === '9-12') {
    query += 'IN (\'9A\', \'9B\', \'9C\', \'9D\', \'9E\', \'9F\', \'9G\', \'9H\', ' +
             '\'10A\', \'10B\', \'10C\', \'10D\', \'10E\', \'10F\', \'10G\', \'10H\', ' +
             '\'11A\', \'11B\', \'11C\', \'11D\', \'11E\', \'11F\', \'11G\', \'11H\', ' +
             '\'12A\', \'12B\', \'12C\', \'12D\', \'12E\', \'12F\', \'12G\', \'12H\')';
  } else {
    res.status(400).json({ message: 'Invalid school range' });
    return;
  }
  query += ' ORDER BY serial_no ASC LIMIT $1 OFFSET $2';

  try {
    const result = await pool.query(query, [limit, offset]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching student list:', err);
    res.status(500).json({ message: 'Failed to fetch student list. Please try again.' });
  }
});

app.post('/addStudent', async (req, res) => {
  const {
    student_name, father_name, mother_name, address, mobile_number, class_section
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO student_list (student_name, father_name, mother_name, address, mobile_number, class_section)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [student_name, father_name, mother_name, address, mobile_number, class_section]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding student:', err);
    res.status(500).json({ message: 'Failed to add student. Please try again.' });
  }
});

app.put('/updateStudent/:id', async (req, res) => {
  const { id } = req.params;
  const {
    student_name, father_name, mother_name, address, mobile_number, class_section
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE student_list
       SET student_name = $1, father_name = $2, mother_name = $3, address = $4, mobile_number = $5, class_section = $6
       WHERE serial_no = $7
       RETURNING *`,
      [student_name, father_name, mother_name, address, mobile_number, class_section, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating student:', err);
    res.status(500).json({ message: 'Failed to update student. Please try again.' });
  }
});

app.delete('/deleteStudent/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query('DELETE FROM student_list WHERE serial_no = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting student:', err);
    res.status(500).json({ message: 'Failed to delete student. Please try again.' });
  }
});

app.post('/submitApplication', async (req, res) => {
  const {
    firstName, lastName, email, phoneNumber, address, dob,
    aadharNumber, motherName, fatherName, fatherOccupation, guardianName,
    guardianAddress, residenceDuration, religion, caste, nationality,
    birthCertificate, lastInstitution, attendanceYear, class: studentClass,
    publicExamination, subjects, siblingsCurrentlyStudying, siblingsPreviouslyStudied, section
  } = req.body;

  const classWithSection = `${studentClass}-${section}`;

  try {
    // Insert application data into student_application table
    const result = await pool.query(
      `INSERT INTO student_application (first_name, last_name, email, phone_number, address, dob, aadhar_number, mother_name,
       father_name, father_occupation, guardian_name, guardian_address, residence_duration, religion, caste, nationality,
       birth_certificate, last_institution, attendance_year, class, public_examination, subjects, siblings_currently_studying, siblings_previously_studied)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24)
       RETURNING *`,
      [firstName, lastName, email, phoneNumber, address, dob, aadharNumber, motherName,
        fatherName, fatherOccupation, guardianName, guardianAddress, residenceDuration, religion, caste, nationality,
        birthCertificate, lastInstitution, attendanceYear, classWithSection, publicExamination, subjects, siblingsCurrentlyStudying, siblingsPreviouslyStudied]
    );

    const newStudent = result.rows[0];
    const studentId = newStudent.student_id;

    // Insert student data into student_list table without specifying serial_no
    const studentListResult = await pool.query(
      `INSERT INTO student_list (student_name, father_name, mother_name, address, mobile_number, class_section)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [`${firstName} ${lastName}`, fatherName, motherName, address, phoneNumber, classWithSection]
    );

    res.status(201).json(newStudent);
  } catch (err) {
    console.error('Error submitting application:', err);
    res.status(500).json({ message: 'Failed to submit application. Please try again.' });
  }
});

app.get('/student-count-per-month/:financialYear', async (req, res) => {
  const { financialYear } = req.params;
  try {
    const result = await pool.query(
      `SELECT admission_month, COUNT(*) AS student_count
       FROM student_application
       WHERE financial_year = $1
       GROUP BY admission_month
       ORDER BY admission_month`,
      [financialYear]
    );
    const data = result.rows.reduce((acc, row) => {
      acc[row.admission_month] = parseInt(row.student_count, 10);
      return acc;
    }, {});
    res.status(200).json(data);
  } catch (err) {
    console.error('Error fetching student count:', err);
    res.status(500).json({ message: 'Failed to fetch student count. Please try again.' });
  }
});

// Endpoint to record fee payment
app.post('/feePayment', upload.single('paymentProof'), async (req, res) => {
  const { studentId, amount, transactionId, paymentMode } = req.body;
  const paymentProofPath = req.file.path;

  if (!isValidInteger(studentId)) {
    return res.status(400).json({ message: 'Invalid student ID' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO fee_payments (student_id, amount, transaction_id, payment_mode, payment_proof_path)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [studentId, amount, transactionId, paymentMode, paymentProofPath]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error recording fee payment:', err);
    res.status(500).json({ message: 'Failed to record fee payment. Please try again.' });
  }
});

// Endpoint to fetch student application details and documents
app.get('/student/:studentId', async (req, res) => {
  const { studentId } = req.params;

  try {
    const studentResult = await pool.query('SELECT * FROM student_application WHERE student_id = $1', [studentId]);
    const documentsResult = await pool.query('SELECT * FROM student_documents WHERE student_id = $1', [studentId]);
    const feeResult = await pool.query('SELECT * FROM fee_payments WHERE student_id = $1', [studentId]);

    if (studentResult.rows.length > 0) {
      const studentDetails = studentResult.rows[0];
      const documents = documentsResult.rows;
      const fees = feeResult.rows;
      res.status(200).json({ studentDetails, documents, fees });
    } else {
      res.status(404).json({ message: 'Student not found' });
    }
  } catch (err) {
    console.error('Error fetching student details:', err);
    res.status(500).json({ message: 'Failed to fetch student details. Please try again.' });
  }
});

app.get('/student-applications', async (req, res) => {
  try {
    const { classFilter, studentId, month, year } = req.query;

    let query = 'SELECT * FROM student_application';
    const params = [];

    if (studentId) {
      query += ' WHERE student_id = $1';
      params.push(studentId);
    } else {
      const filters = [];
      if (classFilter && classFilter !== 'All') {
        filters.push(`class = $${params.length + 1}`);
        params.push(classFilter);
      }
      if (month) {
        filters.push(`EXTRACT(MONTH FROM dob) = $${params.length + 1}`);
        params.push(new Date(Date.parse(month + " 1, 2024")).getMonth() + 1);
      }
      if (year) {
        filters.push(`EXTRACT(YEAR FROM dob) = $${params.length + 1}`);
        params.push(year);
      }
      if (filters.length > 0) {
        query += ' WHERE ' + filters.join(' AND ');
      }
    }

    query += ' ORDER BY student_id';

    const studentResult = await pool.query(query, params);
    const documentsResult = await pool.query('SELECT * FROM student_documents');
    const feesResult = await pool.query('SELECT * FROM fee_payments');

    const applications = studentResult.rows.map(student => {
      const documents = documentsResult.rows.filter(doc => doc.student_id === student.student_id);
      const fees = feesResult.rows.filter(fee => fee.student_id === student.student_id);
      return {
        ...student,
        documents,
        fees,
      };
    });

    res.status(200).json({ applications, totalCount: studentResult.rows.length });
  } catch (err) {
    console.error('Error fetching applications:', err);
    res.status(500).json({ message: 'Failed to fetch applications. Please try again.' });
  }
});

app.delete('/student-applications/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM student_application WHERE student_id = $1 RETURNING *', [id]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Student not found' });
    }
  } catch (err) {
    console.error('Error deleting student record:', err);
    res.status(500).json({ message: 'Failed to delete student record. Please try again.' });
  }
});

// Fetch all expenditure master items
app.get('/expenditure-master', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM expenditure_master ORDER BY item_id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching expenditure master items:', err);
    res.status(500).json({ message: 'Failed to fetch expenditure master items. Please try again.' });
  }
});

// Add a new expenditure master item
app.post('/expenditure-master', async (req, res) => {
  const { item_description } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO expenditure_master (item_description) VALUES ($1) RETURNING *',
      [item_description]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding expenditure master item:', err);
    res.status(500).json({ message: 'Failed to add expenditure master item. Please try again.' });
  }
});

// Edit an expenditure master item
app.patch('/expenditure-master/:item_id', async (req, res) => {
  const { item_id } = req.params;
  const { item_description } = req.body;

  try {
    const result = await pool.query(
      'UPDATE expenditure_master SET item_description = $1 WHERE item_id = $2 RETURNING *',
      [item_description, item_id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing expenditure master item:', err);
    res.status(500).json({ message: 'Failed to edit expenditure master item. Please try again.' });
  }
});

// Delete an expenditure master item
app.delete('/expenditure-master/:item_id', async (req, res) => {
  const { item_id } = req.params;

  try {
    const result = await pool.query('DELETE FROM expenditure_master WHERE item_id = $1 RETURNING *', [item_id]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Expenditure master item not found' });
    }
  } catch (err) {
    console.error('Error deleting expenditure master item:', err);
    res.status(500).json({ message: 'Failed to delete expenditure master item. Please try again.' });
  }
});


// Fetch categories
app.get('/categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM expenditure_master ORDER BY item_id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching categories:', err);
    res.status(500).json({ message: 'Failed to fetch categories. Please try again.' });
  }
});

app.post('/expenditures', async (req, res) => {
  const {
    category, description, amount, staffName, staffId,
    paymentMode, date, month, year
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO expenditures (category, description, amount, staff_name, staff_id, payment_mode, date, month, year)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [category, description, amount, staffName, staffId, paymentMode, date, month, year]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding expenditure:', err);
    res.status(500).json({ message: 'Failed to add expenditure. Please try again.' });
  }
});

app.patch('/expenditures/:id', async (req, res) => {
  const { id } = req.params;
  const {
    category, description, amount, staffName, staffId,
    paymentMode, date, month, year
  } = req.body;

  const fieldsToUpdate = [];
  const valuesToUpdate = [];

  if (category !== undefined) {
    fieldsToUpdate.push('category');
    valuesToUpdate.push(category);
  }
  if (description !== undefined) {
    fieldsToUpdate.push('description');
    valuesToUpdate.push(description);
  }
  if (amount !== undefined) {
    fieldsToUpdate.push('amount');
    valuesToUpdate.push(amount);
  }
  if (staffName !== undefined) {
    fieldsToUpdate.push('staff_name');
    valuesToUpdate.push(staffName);
  }
  if (staffId !== undefined) {
    fieldsToUpdate.push('staff_id');
    valuesToUpdate.push(staffId);
  }
  if (paymentMode !== undefined) {
    fieldsToUpdate.push('payment_mode');
    valuesToUpdate.push(paymentMode);
  }
  if (date !== undefined) {
    fieldsToUpdate.push('date');
    valuesToUpdate.push(date);
  }
  if (month !== undefined) {
    fieldsToUpdate.push('month');
    valuesToUpdate.push(month);
  }
  if (year !== undefined) {
    fieldsToUpdate.push('year');
    valuesToUpdate.push(year);
  }

  if (fieldsToUpdate.length === 0) {
    return res.status(400).json({ message: 'No fields provided for update.' });
  }

  const setClause = fieldsToUpdate.map((field, index) => `${field} = $${index + 1}`).join(', ');

  try {
    const result = await pool.query(
      `UPDATE expenditures SET ${setClause} WHERE id = $${fieldsToUpdate.length + 1} RETURNING *`,
      [...valuesToUpdate, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating expenditure:', err);
    res.status(500).json({ message: 'Failed to update expenditure. Please try again.' });
  }
});

app.get('/expenditures', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM expenditures ORDER BY date DESC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching expenditures:', err);
    res.status(500).json({ message: 'Failed to fetch expenditures. Please try again.' });
  }
});

// Fetch specific expenditure by ID
app.get('/expenditures/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('SELECT * FROM expenditures WHERE id = $1', [id]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Expenditure not found' });
    }
  } catch (err) {
    console.error('Error fetching expenditure:', err);
    res.status(500).json({ message: 'Failed to fetch expenditure. Please try again.' });
  }
});

// Fetch all expenditures
app.get('/expenditures', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM expenditures ORDER BY date DESC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching expenditures:', err);
    res.status(500).json({ message: 'Failed to fetch expenditures. Please try again.' });
  }
});

// Delete an expenditure
app.delete('/expenditures/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM expenditures WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Expenditure not found' });
    }
  } catch (err) {
    console.error('Error deleting expenditure:', err);
    res.status(500).json({ message: 'Failed to delete expenditure. Please try again.' });
  }
});

app.get('/students/:className', async (req, res) => {
  const { className } = req.params;
  console.log(`Fetching students for class: ${className}`);

  try {
    const result = await pool.query(
      'SELECT student_id, first_name, last_name FROM student_application WHERE class = $1',
      [className]
    );
    if (result.rows.length > 0) {
      res.status(200).json(result.rows);
    } else {
      res.status(404).json({ message: 'No students found for the specified class.' });
    }
  } catch (err) {
    console.error('Error executing query:', err);
    res.status(500).json({ message: 'Error fetching students from the database.' });
  }
});

// Fetch fees records and calculate total fee
app.post('/fees-record', async (req, res) => {
  const {
    class: studentClass,
    student_name,
    student_type,
    parent_name,
    contact_number,
    address,
    payment_mode,
    submitted_to,
    fees_amount,
    year,
    month,
  } = req.body;

  try {
    const totalFees = await calculateTotalFee(studentClass, student_type, year);
    const pendingFee = totalFees - fees_amount;

    const result = await pool.query(
      `INSERT INTO feesrecord (class, student_name, student_type, parent_name, contact_number, address,
        payment_mode, submitted_to, fees_amount, year, month, total_fee, pending_fee)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING *`,
      [studentClass, student_name, student_type, parent_name, contact_number, address,
        payment_mode, submitted_to, fees_amount, year, month, totalFees, pendingFee]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding fees record:', err);
    res.status(500).json({ message: 'Failed to add fees record. Please try again.' });
  }
});

// Fetch fees records
app.get('/fees-records', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM feesrecord ORDER BY date DESC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching fees records:', err);
    res.status(500).json({ message: 'Failed to fetch fees records. Please try again.' });
  }
});

// Fetch students for a specific class
app.get('/students/:class', async (req, res) => {
  const { class: studentClass } = req.params;

  try {
    const result = await pool.query('SELECT first_name, last_name FROM student_application WHERE class = $1', [studentClass]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

// Signup
app.post('/signup', async (req, res) => {
  const { username, email, password, role, employeeNo, mobileNo, address, department, designation } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      'INSERT INTO users (username, email, password, role, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [username, email, hashedPassword, role, 'pending']
    );

    const newUser = result.rows[0];

    // Add to staff_list if role is teacher, admin, or accountant
    if (['teacher', 'admin', 'accountant'].includes(role)) {
      await pool.query(
        'INSERT INTO staff_list (name, employee_no, mobile_no, email, address, department, designation) VALUES ($1, $2, $3, $4, $5, $6, $7)',
        [username, employeeNo, mobileNo, email, address, department, designation]
      );
    }

    res.status(201).json(newUser);
  } catch (err) {
    console.error('Error during signup:', err);
    res.status(500).json({ message: 'Failed to sign up. Please try again.' });
  }
});

// Login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length > 0) {
      const user = result.rows[0];
      const validPassword = await bcrypt.compare(password, user.password);
      if (validPassword) {
        if (user.role !== 'admin' && user.status !== 'approved') {
          return res.status(403).json({ message: 'Your account is not approved yet.' });
        }

        const token = jwt.sign(
          { id: user.id, role: user.role },
          secretKey, // Use the defined secret key here
          { expiresIn: '1h' }
        );
        res.status(200).json({ token, role: user.role, status: user.status, userId: user.id, email: user.email }); // Include email
      } else {
        res.status(401).json({ message: 'Invalid email or password' });
      }
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (err) {
    console.error('Error during login:', err);
    res.status(500).json({ message: 'Failed to log in. Please try again.' });
  }
});

// Fetch pending approval requests
app.get('/pendingRequests', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE status = $1', ['pending']);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching pending requests:', err);
    res.status(500).json({ message: 'Failed to fetch pending requests. Please try again.' });
  }
});

// Update user status (approve or reject)
app.post('/updateStatus', async (req, res) => {
  const { userId, status } = req.body;

  try {
    await pool.query('UPDATE users SET status = $1 WHERE id = $2', [status, userId]);
    res.status(200).json({ message: 'Status updated successfully' });
  } catch (err) {
    console.error('Error updating status:', err);
    res.status(500).json({ message: 'Failed to update status. Please try again.' });
  }
});

const verifyToken = (roles) => (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(403).json({ message: 'No token provided.' });
  }

  jwt.verify(token.split(' ')[1], secretKey, (err, decoded) => { // Extract the token from 'Bearer <token>'
    if (err) {
      return res.status(500).json({ message: 'Failed to authenticate token.' });
    }

    req.userId = decoded.id;
    req.role = decoded.role;

    if (roles.includes(decoded.role)) {
      next();
    } else {
      res.status(403).json({ message: 'Access denied.' });
    }
  });
};

// Routes for different roles
app.get('/admissions', verifyToken(['admin']), (req, res) => {
  res.status(200).json({ message: 'Welcome to admissions!' });
});

app.get('/fees', verifyToken(['admin', 'teacher', 'accountant']), (req, res) => {
  res.status(200).json({ message: 'Welcome to fees!' });
});

app.get('/expenditures', verifyToken(['admin', 'accountant']), (req, res) => {
  res.status(200).json({ message: 'Welcome to expenditures!' });
});


// Fetch fees master for a specific class and financial year
app.get('/fees-master/:classId/:financialYear/:studentType', async (req, res) => {
  const { classId, financialYear, studentType } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM fees_master WHERE class = $1 AND financial_year = $2 AND student_type = $3',
      [classId, financialYear, studentType]
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching fees master:', err);
    res.status(500).json({ message: 'Failed to fetch fees master. Please try again.' });
  }
});

async function calculateTotalFee(classId, studentType, financialYear) {
  try {
    const result = await pool.query(
      'SELECT * FROM fees_master WHERE class = $1 AND financial_year = $2 AND student_type = $3',
      [classId, financialYear, studentType]
    );

    if (result.rows.length === 0) {
      return 0;
    }

    const fees = result.rows;
    return fees.reduce((total, fee) => total + parseFloat(fee.amount), 0.0);
  } catch (err) {
    console.error('Error calculating total fee:', err);
    throw err;
  }
}


// Add or update fee master record
app.post('/fees-master', async (req, res) => {
  const { classId, studentType, financialYear, feeName, amount } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO fees_master (class, student_type, financial_year, fee_name, amount)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (class, student_type, financial_year, fee_name)
       DO UPDATE SET amount = $5
       RETURNING *`,
      [classId, studentType, financialYear, feeName, amount]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding/updating fee master:', err);
    res.status(500).json({ message: 'Failed to add/update fee master. Please try again.' });
  }
});

// Delete a fee master record
app.delete('/fees-master/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM fees_master WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Fee master record not found' });
    }
  } catch (err) {
    console.error('Error deleting fee master record:', err);
    res.status(500).json({ message: 'Failed to delete fee master record. Please try again.' });
  }
});

// Assuming you're joining the holidays table with holiday_master to get the type
app.get('/holidays', async (req, res) => {
  const query = `
    SELECT h.id, h.start_date, h.end_date, hm.name AS holiday_name, hm.type AS holiday_type
    FROM holidays h
    JOIN holiday_master hm ON h.name_id = hm.id
    ORDER BY h.start_date;
  `;

  try {
    const client = await pool.connect();
    const result = await client.query(query);
    const holidays = result.rows;
    client.release();
    res.json(holidays);
  } catch (err) {
    console.error('Error fetching holidays', err);
    res.status(500).send('Error fetching holidays');
  }
});

// POST new holiday
app.post('/holidays', async (req, res) => {
  const { name_id, start_date, end_date } = req.body;

  try {
    const insertQuery = 'INSERT INTO holidays (name_id, start_date, end_date) VALUES ($1, $2, $3) RETURNING *';
    const result = await pool.query(insertQuery, [name_id, start_date, end_date]);
    const insertedHoliday = result.rows[0];
    res.status(201).json(insertedHoliday);
  } catch (err) {
    console.error('Error adding holiday', err);
    res.status(500).send('Error adding holiday');
  }
});

// PUT update holiday
app.put('/holidays/:id', async (req, res) => {
  const id = req.params.id;
  const { name_id, start_date, end_date } = req.body;
  try {
    const client = await pool.connect();
    const result = await client.query(
      'UPDATE holidays SET name_id = $1, start_date = $2, end_date = $3 WHERE id = $4 RETURNING *',
      [name_id, start_date, end_date, id]
    );
    const updatedHoliday = result.rows[0];
    client.release();
    res.json(updatedHoliday);
  } catch (err) {
    console.error('Error updating holiday', err);
    res.status(500).send('Error updating holiday');
  }
});

// DELETE holiday
app.delete('/holidays/:id', async (req, res) => {
  const id = req.params.id;
  try {
    const client = await pool.connect();
    await client.query('DELETE FROM holidays WHERE id = $1', [id]);
    client.release();
    res.sendStatus(204);
  } catch (err) {
    console.error('Error deleting holiday', err);
    res.status(500).send('Error deleting holiday');
  }
});

app.get('/holiday_master', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT * FROM holiday_master');
    const holidayMaster = result.rows;
    client.release();
    res.json(holidayMaster);
  } catch (err) {
    console.error('Error fetching holiday master data', err);
    res.status(500).send('Error fetching holiday master data');
  }
});

// Send Notification
app.post('/send_notification', verifyToken(['admin']), async (req, res) => {
  const { message, recipient_type, user_id } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO notifications (message, recipient_type, user_id, created_at)
      VALUES ($1, $2, $3, NOW()) RETURNING *`,
      [message, recipient_type, user_id]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error sending notification:', err);
    res.status(500).json({ message: 'Failed to send notification. Please try again.', error: err });
  }
});

// Get Notifications for a user
app.get('/get_notifications/:user_id', verifyToken(['admin', 'teacher', 'accountant', 'student']), async (req, res) => {
  const { user_id } = req.params;

  try {
    const userResult = await pool.query('SELECT role FROM users WHERE id = $1', [user_id]);
    const role = userResult.rows[0].role;

    const result = await pool.query(`
      SELECT * FROM notifications
      WHERE recipient_type = 'All'
      OR (recipient_type = 'Teachers' AND $1 = 'teacher')
      OR (recipient_type = 'Accountants' AND $1 = 'accountant')
      OR (user_id = $2)
      ORDER BY created_at DESC
    `, [role, user_id]);

    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching notifications:', err);
    res.status(500).json({ message: 'Failed to fetch notifications. Please try again.' });
  }
});

// Fetch book categories
app.get('/book-categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM category_master ORDER BY id ASC');
    console.log('Fetched book categories:', result.rows); // Debug print
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching book categories:', err);
    res.status(500).json({ message: 'Failed to fetch book categories. Please try again.' });
  }
});

// Get a single book category by id
app.get('/book-categories/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM category_master WHERE id = $1', [req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Create a new book category
app.post('/book-categories', async (req, res) => {
  try {
    const { book_category_name, order_no } = req.body;
    const result = await pool.query('INSERT INTO category_master (book_category_name, order_no) VALUES ($1, $2) RETURNING *', [book_category_name, order_no]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Update a book category by id
app.put('/book-categories/:id', async (req, res) => {
  try {
    const { book_category_name, order_no } = req.body;
    const result = await pool.query('UPDATE category_master SET book_category_name = $1, order_no = $2 WHERE id = $3 RETURNING *', [book_category_name, order_no, req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Delete a book category by id
app.delete('/book-categories/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM category_master WHERE id = $1', [req.params.id]);
    res.status(204).send();
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Sub Category Master
app.get('/subcategories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sub_category_master');
    res.status(200).json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.get('/subcategories/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sub_category_master WHERE id = $1', [req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.post('/subcategories', async (req, res) => {
  try {
    const { name, order_no } = req.body;
    const result = await pool.query('INSERT INTO sub_category_master (name, order_no) VALUES ($1, $2) RETURNING *', [name, order_no]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.put('/subcategories/:id', async (req, res) => {
  try {
    const { name, order_no } = req.body;
    const result = await pool.query('UPDATE sub_category_master SET name = $1, order_no = $2 WHERE id = $3 RETURNING *', [name, order_no, req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.delete('/subcategories/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM sub_category_master WHERE id = $1', [req.params.id]);
    res.status(204).send();
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Book Publisher Master
app.get('/publishers', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM book_publisher');
    res.status(200).json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.get('/publishers/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM book_publisher WHERE id = $1', [req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.post('/publishers', async (req, res) => {
  try {
    const { publisher_name, phone_no, email_address, address } = req.body;
    const result = await pool.query('INSERT INTO book_publisher (publisher_name, phone_no, email_address, address) VALUES ($1, $2, $3, $4) RETURNING *', [publisher_name, phone_no, email_address, address]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.put('/publishers/:id', async (req, res) => {
  try {
    const { publisher_name, phone_no, email_address, address } = req.body;
    const result = await pool.query('UPDATE book_publisher SET publisher_name = $1, phone_no = $2, email_address = $3, address = $4 WHERE id = $5 RETURNING *', [publisher_name, phone_no, email_address, address, req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.delete('/publishers/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM book_publisher WHERE id = $1', [req.params.id]);
    res.status(204).send();
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Book Master
app.get('/books', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM book_master');
    res.status(200).json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.get('/books/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM book_master WHERE id = $1', [req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.post('/books', async (req, res) => {
  try {
    const { accession_no, book_name, author, publisher_id, category_id, sub_category_id, location, bar_code } = req.body;
    const result = await pool.query('INSERT INTO book_master (accession_no, book_name, author, publisher_id, category_id, sub_category_id, location, bar_code) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *', [accession_no, book_name, author, publisher_id, category_id, sub_category_id, location, bar_code]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.put('/books/:id', async (req, res) => {
  try {
    const { accession_no, book_name, author, publisher_id, category_id, sub_category_id, location, bar_code } = req.body;
    const result = await pool.query('UPDATE book_master SET accession_no = $1, book_name = $2, author = $3, publisher_id = $4, category_id = $5, sub_category_id = $6, location = $7, bar_code = $8 WHERE id = $9 RETURNING *', [accession_no, book_name, author, publisher_id, category_id, sub_category_id, location, bar_code, req.params.id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.delete('/books/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM book_master WHERE id = $1', [req.params.id]);
    res.status(204).send();
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Get all issued books
app.get('/issued_books', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT ib.id, c.book_category_name AS category, sc.name AS sub_category, bm.book_name AS book, ib.student_id, sa.first_name || ' ' || sa.last_name AS name, ib.quantity, ib.issue_date, ib.receive_date
      FROM issued_books ib
      JOIN category_master c ON ib.category_id = c.id
      JOIN sub_category_master sc ON ib.sub_category_id = sc.id
      JOIN book_master bm ON ib.book_id = bm.id
      LEFT JOIN student_application sa ON ib.student_id = sa.student_id
      ORDER BY ib.issue_date DESC
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching issued books:', err);
    res.status(500).json({ message: 'Failed to fetch issued books. Please try again.' });
  }
});

// Issue a new book
app.post('/issue_book', async (req, res) => {
  const { book_id, category_id, sub_category_id, student_id, quantity, issue_date, receive_date } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO issued_books (book_id, category_id, sub_category_id, student_id, quantity, issue_date, receive_date) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [book_id, category_id, sub_category_id, student_id, quantity, issue_date, receive_date]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error issuing book:', err);
    res.status(500).json({ message: 'Failed to issue book. Please try again.' });
  }
});

app.get('/students', async (req, res) => {
  try {
    const result = await pool.query('SELECT student_id, first_name, last_name FROM student_application');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

// Get all received books
app.get('/received_books', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT rb.id, bm.book_name AS book, sa.first_name || ' ' || sa.last_name AS issued_name, rb.quantity, rb.issue_date, rb.return_date, rb.received_date, rb.fine, rb.paid, rb.remarks
      FROM received_books rb
      JOIN book_master bm ON rb.book_id = bm.id
      LEFT JOIN student_application sa ON rb.issued_to = sa.student_id
      ORDER BY rb.received_date DESC
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching received books:', err);
    res.status(500).json({ message: 'Failed to fetch received books. Please try again.' });
  }
});

// Receive a book
app.post('/receive_book', async (req, res) => {
  const { book_id, issued_to, quantity, issue_date, return_date, received_date, fine, paid, remarks } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO received_books
      (book_id, issued_to, quantity, issue_date, return_date, received_date, fine, paid, remarks)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *`,
      [book_id, issued_to, quantity, issue_date, return_date, received_date, fine, paid, remarks]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error receiving book:', err);
    res.status(500).json({ message: 'Failed to receive book. Please try again.' });
  }
});

// Get book availability
app.get('/book_availability', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT ba.id, bm.book_name, cm.book_category_name, ba.total_quantity, ba.issued_quantity, ba.available_quantity, ba.next_availability,
      CASE
        WHEN ba.available_quantity > 0 THEN 'Yes'
        ELSE 'No'
      END AS issuable
      FROM book_availability ba
      JOIN book_master bm ON ba.book_id = bm.id
      JOIN category_master cm ON bm.category_id = cm.id
      ORDER BY bm.book_name
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching book availability:', err);
    res.status(500).json({ message: 'Failed to fetch book availability. Please try again.' });
  }
});

// Get next availability date for a book
app.get('/next_availability/:book_id', async (req, res) => {
  const { book_id } = req.params;

  try {
    const result = await pool.query(`
      SELECT received_date, quantity
      FROM received_books
      WHERE book_id = $1
      ORDER BY received_date ASC
    `, [book_id]);

    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching next availability:', err);
    res.status(500).json({ message: 'Failed to fetch next availability. Please try again.' });
  }
});

// Get student library records
app.get('/student_library_records', async (req, res) => {
  const { search } = req.query;

  try {
    let query = `
      SELECT ib.id, sa.student_id, sa.first_name || ' ' || sa.last_name AS name, bm.book_name, ib.issue_date, ib.receive_date, 0 AS fines, 'NA' AS fine_paid
      FROM issued_books ib
      JOIN book_master bm ON ib.book_id = bm.id
      JOIN student_application sa ON ib.student_id = sa.student_id
    `;

    if (search) {
      query += ` WHERE sa.first_name ILIKE '%${search}%' OR sa.last_name ILIKE '%${search}%' OR sa.student_id::text ILIKE '%${search}%'`;
    }

    query += ' ORDER BY ib.issue_date DESC';

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching student library records:', err);
    res.status(500).json({ message: 'Failed to fetch student library records. Please try again.' });
  }
});

// Get fines records
app.get('/library_fines', async (req, res) => {
  const { search } = req.query;

  try {
    let query = `
      SELECT rb.id, sa.student_id, sa.first_name || ' ' || sa.last_name AS name, bm.book_name, rb.fine, rb.paid, rb.received_date AS deposit_date, rb.remarks
      FROM received_books rb
      JOIN book_master bm ON rb.book_id = bm.id
      JOIN student_application sa ON rb.issued_to = sa.student_id
    `;

    if (search) {
      query += ` WHERE sa.first_name ILIKE '%${search}%' OR sa.last_name ILIKE '%${search}%' OR sa.student_id::text ILIKE '%${search}%'`;
    }

    query += ' ORDER BY rb.received_date DESC';

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching fines records:', err);
    res.status(500).json({ message: 'Failed to fetch fines records. Please try again.' });
  }
});

// Get issued books report
app.get('/issued_books_report', async (req, res) => {
  const { fromDate, toDate, bookName, issueType, studentName, classSection } = req.query;

  try {
    let query = `
      SELECT ib.id, bm.book_name, bm.accession_no, ib.issue_date, ib.receive_date, sa.first_name || ' ' || sa.last_name AS student_name, sa.class AS class_section
      FROM issued_books ib
      JOIN book_master bm ON ib.book_id = bm.id
      JOIN student_application sa ON ib.student_id = sa.student_id
      WHERE 1=1
    `;

    if (fromDate) {
      query += ` AND ib.issue_date >= '${fromDate}'`;
    }
    if (toDate) {
      query += ` AND ib.issue_date <= '${toDate}'`;
    }
    if (bookName) {
      query += ` AND (bm.book_name ILIKE '%${bookName}%' OR bm.accession_no ILIKE '%${bookName}%')`;
    }
    if (issueType) {
      query += ` AND ib.issue_type = '${issueType}'`;
    }
    if (studentName) {
      query += ` AND (sa.first_name ILIKE '%${studentName}%' OR sa.last_name ILIKE '%${studentName}%')`;
    }
    if (classSection) {
      query += ` AND sa.class = '${classSection}'`;
    }

    query += ' ORDER BY ib.issue_date DESC';

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching issued books report:', err);
    res.status(500).json({ message: 'Failed to fetch issued books report. Please try again.' });
  }
});

// Generate PDF report
app.get('/issued_books_report/pdf', async (req, res) => {
  const { fromDate, toDate, bookName, issueType, studentName, classSection } = req.query;

  try {
    // Fetch records as in the /issued_books_report endpoint
    // Create PDF document using the fetched records
    const records = await getIssuedBooksReport(fromDate, toDate, bookName, issueType, studentName, classSection);

    const html = `
      <html>
        <head>
          <style>
            table {
              width: 100%;
              border-collapse: collapse;
            }
            th, td {
              border: 1px solid black;
              padding: 8px;
              text-align: left;
            }
          </style>
        </head>
        <body>
          <h2>Monthly Issued Books Report</h2>
          <table>
            <tr>
              <th>ID</th>
              <th>Book Name</th>
              <th>Accession No</th>
              <th>Issue Date</th>
              <th>Receive Date</th>
              <th>Student Name</th>
              <th>Class & Section</th>
            </tr>
            ${records.map(record => `
              <tr>
                <td>${record.id}</td>
                <td>${record.book_name}</td>
                <td>${record.accession_no}</td>
                <td>${record.issue_date}</td>
                <td>${record.receive_date}</td>
                <td>${record.student_name}</td>
                <td>${record.class_section}</td>
              </tr>
            `).join('')}
          </table>
        </body>
      </html>
    `;

    pdf.create(html).toStream((err, stream) => {
      if (err) return res.status(500).json({ message: 'Failed to generate PDF report.' });
      res.setHeader('Content-type', 'application/pdf');
      stream.pipe(res);
    });
  } catch (err) {
    console.error('Error generating PDF report:', err);
    res.status(500).json({ message: 'Failed to generate PDF report. Please try again.' });
  }
});

// Generate Excel report
app.get('/issued_books_report/excel', async (req, res) => {
  const { fromDate, toDate, bookName, issueType, studentName, classSection } = req.query;

  try {
    // Fetch records as in the /issued_books_report endpoint
    const records = await getIssuedBooksReport(fromDate, toDate, bookName, issueType, studentName, classSection);

    const workbook = new excel.Workbook();
    const worksheet = workbook.addWorksheet('Monthly Issued Books Report');

    worksheet.columns = [
      { header: 'ID', key: 'id', width: 10 },
      { header: 'Book Name', key: 'book_name', width: 30 },
      { header: 'Accession No', key: 'accession_no', width: 30 },
      { header: 'Issue Date', key: 'issue_date', width: 15 },
      { header: 'Receive Date', key: 'receive_date', width: 15 },
      { header: 'Student Name', key: 'student_name', width: 30 },
      { header: 'Class & Section', key: 'class_section', width: 15 },
    ];

    worksheet.addRows(records);

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=issued_books_report.xlsx');

    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    console.error('Error generating Excel report:', err);
    res.status(500).json({ message: 'Failed to generate Excel report. Please try again.' });
  }
});

// Helper function to get issued books report
async function getIssuedBooksReport(fromDate, toDate, bookName, issueType, studentName, classSection) {
  let query = `
    SELECT ib.id, bm.book_name, bm.accession_no, ib.issue_date, ib.receive_date, sa.first_name || ' ' || sa.last_name AS student_name, sa.class AS class_section
    FROM issued_books ib
    JOIN book_master bm ON ib.book_id = bm.id
    JOIN student_application sa ON ib.student_id = sa.student_id
    WHERE 1=1
  `;

  if (fromDate) {
    query += ` AND ib.issue_date >= '${fromDate}'`;
  }
  if (toDate) {
    query += ` AND ib.issue_date <= '${toDate}'`;
  }
  if (bookName) {
    query += ` AND (bm.book_name ILIKE '%${bookName}%' OR bm.accession_no ILIKE '%${bookName}%')`;
  }
  if (issueType) {
    query += ` AND ib.issue_type = '${issueType}'`;
  }
  if (studentName) {
    query += ` AND (sa.first_name ILIKE '%${studentName}%' OR sa.last_name ILIKE '%${studentName}%')`;
  }
  if (classSection) {
    query += ` AND sa.class = '${classSection}'`;
  }

  query += ' ORDER BY ib.issue_date DESC';

  const result = await pool.query(query);
  return result.rows;
}

// Get stock report
app.get('/stock_report', async (req, res) => {
  const { search } = req.query;

  try {
    let query = `
      SELECT cm.book_category_name, COUNT(bs.id) AS total_books, SUM(bs.total_quantity) AS total_quantity,
             SUM(bs.issued_quantity) AS issued_books, (SUM(bs.total_quantity) - SUM(bs.issued_quantity)) AS available_books,
             bs.location
      FROM book_stock bs
      JOIN book_master bm ON bs.book_id = bm.id
      JOIN category_master cm ON bm.category_id = cm.id
      WHERE 1=1
    `;

    if (search) {
      query += ` AND (cm.book_category_name ILIKE '%${search}%' OR bm.book_name ILIKE '%${search}%')`;
    }

    query += `
      GROUP BY cm.book_category_name, bs.location
      ORDER BY cm.book_category_name
    `;

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching stock report:', err);
    res.status(500).json({ message: 'Failed to fetch stock report. Please try again.' });
  }
});

// Get top user report
app.get('/top_user_report', async (req, res) => {
  const { search } = req.query;

  try {
    let query = `
      SELECT sa.student_id, sa.first_name || ' ' || sa.last_name AS name, sa.gender, sa.class AS class_section, sa.email, sa.phone_number, COUNT(ib.id) AS total_issued_books
      FROM student_application sa
      JOIN issued_books ib ON sa.student_id = ib.student_id
      WHERE 1=1
    `;

    if (search) {
      query += ` AND (sa.first_name ILIKE '%${search}%' OR sa.last_name ILIKE '%${search}%' OR sa.student_id::text ILIKE '%${search}%' OR sa.email ILIKE '%${search}%' OR sa.phone_number ILIKE '%${search}%')`;
    }

    query += `
      GROUP BY sa.student_id, sa.first_name, sa.last_name, sa.gender, sa.class, sa.email, sa.phone_number
      ORDER BY total_issued_books DESC
    `;

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching top user report:', err);
    res.status(500).json({ message: 'Failed to fetch top user report. Please try again.' });
  }
});

// Get staff consolidation report
app.get('/staff_consolidation_report', async (req, res) => {
  const { search } = req.query;

  try {
    let query = `
      SELECT sa.staff_id, sa.first_name || ' ' || sa.last_name AS name, sa.email, sa.phone_number, sa.address, sa.dob, sa.gender, sa.position, COUNT(ib.id) AS total_books
      FROM staff_application sa
      LEFT JOIN issued_books ib ON sa.staff_id = ib.staff_id
      WHERE 1=1
    `;

    if (search) {
      query += ` AND (sa.first_name ILIKE '%${search}%' OR sa.last_name ILIKE '%${search}%' OR sa.staff_id::text ILIKE '%${search}%')`;
    }

    query += `
      GROUP BY sa.staff_id, sa.first_name, sa.last_name, sa.email, sa.phone_number, sa.address, sa.dob, sa.gender, sa.position
      ORDER BY total_books DESC
    `;

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching staff consolidation report:', err);
    res.status(500).json({ message: 'Failed to fetch staff consolidation report. Please try again.' });
  }
});

// Get scrapped books
app.get('/scrapped_books', async (req, res) => {
  const { search } = req.query;

  try {
    let query = `
      SELECT sb.id, cm.book_category_name, bm.book_name, sb.quantity, sb.scrap_date, sb.scrap_reason
      FROM scrapped_books sb
      JOIN book_master bm ON sb.book_id = bm.id
      JOIN category_master cm ON bm.category_id = cm.id
      WHERE 1=1
    `;

    if (search) {
      query += ` AND (cm.book_category_name ILIKE '%${search}%' OR bm.book_name ILIKE '%${search}%')`;
    }

    query += `
      ORDER BY sb.scrap_date DESC
    `;

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching scrapped books:', err);
    res.status(500).json({ message: 'Failed to fetch scrapped books. Please try again.' });
  }
});

// Scrap a book
app.post('/scrap_book', async (req, res) => {
  const { book_id, quantity, scrap_date, scrap_reason } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO scrapped_books (book_id, quantity, scrap_date, scrap_reason) VALUES ($1, $2, $3, $4) RETURNING *',
      [book_id, quantity, scrap_date, scrap_reason]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error scrapping book:', err);
    res.status(500).json({ message: 'Failed to scrap book. Please try again.' });
  }
});

// GET all fuel fillings
app.get('/fuel-fillings', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM fuel_fillings ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error('Error fetching fuel fillings:', err);
    res.status(500).json({ error: 'Failed to fetch fuel fillings' });
  }
});

// GET a single fuel filling by ID
app.get('/fuel-fillings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query('SELECT * FROM fuel_fillings WHERE id = $1', [id]);
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Fuel filling not found' });
    }
  } catch (err) {
    console.error('Error fetching fuel filling:', err);
    res.status(500).json({ error: 'Failed to fetch fuel filling' });
  }
});

// POST a new fuel filling
app.post('/fuel-fillings', async (req, res) => {
  const { vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO fuel_fillings (vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error adding fuel filling:', err);
    res.status(500).json({ error: 'Failed to add fuel filling' });
  }
});

// PUT update an existing fuel filling
app.put('/fuel-fillings/:id', async (req, res) => {
  const { id } = req.params;
  const { vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE fuel_fillings SET vehicle_name = $1, fuel_filling_date = $2, meter_reading = $3, quantity = $4, fuel_price = $5, slip_number = $6 WHERE id = $7 RETURNING *',
      [vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number, id]
    );
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Fuel filling not found' });
    }
  } catch (err) {
    console.error('Error updating fuel filling:', err);
    res.status(500).json({ error: 'Failed to update fuel filling' });
  }
});

// DELETE a fuel filling by ID
app.delete('/fuel-fillings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query('DELETE FROM fuel_fillings WHERE id = $1 RETURNING *', [id]);
    if (rows.length > 0) {
      res.json({ message: 'Fuel filling deleted successfully' });
    } else {
      res.status(404).json({ error: 'Fuel filling not found' });
    }
  } catch (err) {
    console.error('Error deleting fuel filling:', err);
    res.status(500).json({ error: 'Failed to delete fuel filling' });
  }
});


// GET all vehicle maintenance
app.get('/vehicle-maintenance', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM vehicle_maintenance ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error('Error fetching vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to fetch vehicle maintenance' });
  }
});

// GET all maintenance details for a specific maintenance entry
app.get('/maintenance-details/:maintenance_id', async (req, res) => {
  const { maintenance_id } = req.params;
  try {
    const { rows } = await pool.query('SELECT * FROM maintenance_details WHERE maintenance_id = $1 ORDER BY id', [maintenance_id]);
    res.json(rows);
  } catch (err) {
    console.error('Error fetching maintenance details:', err);
    res.status(500).json({ error: 'Failed to fetch maintenance details' });
  }
});

// POST a new vehicle maintenance
app.post('/vehicle-maintenance', async (req, res) => {
  const { vehicle_name, maintenance_date, maintenance_name, meter_reading, details } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO vehicle_maintenance (vehicle_name, maintenance_date, maintenance_name, meter_reading) VALUES ($1, $2, $3, $4) RETURNING *',
      [vehicle_name, maintenance_date, maintenance_name, meter_reading]
    );
    const maintenanceId = rows[0].id;

    for (const detail of details) {
      await pool.query(
        'INSERT INTO maintenance_details (maintenance_id, date, bill_number, vendor_name, amount) VALUES ($1, $2, $3, $4, $5)',
        [maintenanceId, detail.date, detail.bill_number, detail.vendor_name, detail.amount]
      );
    }

    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error adding vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to add vehicle maintenance' });
  }
});

// PUT update an existing vehicle maintenance
app.put('/vehicle-maintenance/:id', async (req, res) => {
  const { id } = req.params;
  const { vehicle_name, maintenance_date, maintenance_name, meter_reading, details } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE vehicle_maintenance SET vehicle_name = $1, maintenance_date = $2, maintenance_name = $3, meter_reading = $4 WHERE id = $5 RETURNING *',
      [vehicle_name, maintenance_date, maintenance_name, meter_reading, id]
    );

    if (rows.length > 0) {
      await pool.query('DELETE FROM maintenance_details WHERE maintenance_id = $1', [id]);
      for (const detail of details) {
        await pool.query(
          'INSERT INTO maintenance_details (maintenance_id, date, bill_number, vendor_name, amount) VALUES ($1, $2, $3, $4, $5)',
          [id, detail.date, detail.bill_number, detail.vendor_name, detail.amount]
        );
      }
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Vehicle maintenance not found' });
    }
  } catch (err) {
    console.error('Error updating vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to update vehicle maintenance' });
  }
});

// DELETE a vehicle maintenance entry
app.delete('/vehicle-maintenance/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rowCount } = await pool.query('DELETE FROM vehicle_maintenance WHERE id = $1', [id]);
    if (rowCount > 0) {
      res.status(204).send();
    } else {
      res.status(404).json({ error: 'Vehicle maintenance not found' });
    }
  } catch (err) {
    console.error('Error deleting vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to delete vehicle maintenance' });
  }
});

// GET all vehicle checklists
app.get('/vehicle-checklist', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM vehicle_checklist ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error('Error fetching vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to fetch vehicle checklist' });
  }
});

// GET a single vehicle checklist by ID
app.get('/vehicle-checklist/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query('SELECT * FROM vehicle_checklist WHERE id = $1', [id]);
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Vehicle checklist not found' });
    }
  } catch (err) {
    console.error('Error fetching vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to fetch vehicle checklist' });
  }
});

// POST a new vehicle checklist
app.post('/vehicle-checklist', async (req, res) => {
  const {
    date,
    vehicle_name,
    driver_name,
    driving_license_renewal_date,
    vehicle_rc,
    insurance_renewal_date,
    pollution_renewal_date,
    mv_tax_date,
    counter_sign_renewal_date,
    passing_renewal_date,
    other_state_tax_renewal_date,
    permit_renewal_date,
    dvr_status,
    medical_box,
    camera1_status,
    camera2_status,
    camera3_status,
    fire_equipment,
    seat_belt,
    challan_if_any,
    route_chart,
    reflector_sticker,
    seat_cover,
    ac,
    gps,
    batches_whistle,
    service,
    washing,
    todays_reading,
    greasing,
    brake_check,
    wheel_alignment,
    check_all_glasses,
    lights_and_reflectors,
    tyre,
    air_check,
  } = req.body;

  try {
    const { rows } = await pool.query(
      `INSERT INTO vehicle_checklist (
         date, vehicle_name, driver_name, driving_license_renewal_date, vehicle_rc,
         insurance_renewal_date, pollution_renewal_date, mv_tax_date, counter_sign_renewal_date,
         passing_renewal_date, other_state_tax_renewal_date, permit_renewal_date, dvr_status,
         medical_box, camera1_status, camera2_status, camera3_status, fire_equipment, seat_belt,
         challan_if_any, route_chart, reflector_sticker, seat_cover, ac, gps, batches_whistle,
         service, washing, todays_reading, greasing, brake_check, wheel_alignment, check_all_glasses,
         lights_and_reflectors, tyre, air_check
       ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35)
       RETURNING *`,
      [
        date,
        vehicle_name,
        driver_name,
        driving_license_renewal_date,
        vehicle_rc,
        insurance_renewal_date,
        pollution_renewal_date,
        mv_tax_date,
        counter_sign_renewal_date,
        passing_renewal_date,
        other_state_tax_renewal_date,
        permit_renewal_date,
        dvr_status,
        medical_box,
        camera1_status,
        camera2_status,
        camera3_status,
        fire_equipment,
        seat_belt,
        challan_if_any,
        route_chart,
        reflector_sticker,
        seat_cover,
        ac,
        gps,
        batches_whistle,
        service,
        washing,
        todays_reading,
        greasing,
        brake_check,
        wheel_alignment,
        check_all_glasses,
        lights_and_reflectors,
        tyre,
        air_check,
      ]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error adding vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to add vehicle checklist' });
  }
});

// PUT update an existing vehicle checklist
app.put('/vehicle-checklist/:id', async (req, res) => {
  const { id } = req.params;
  const {
    date,
    vehicle_name,
    driver_name,
    driving_license_renewal_date,
    vehicle_rc,
    insurance_renewal_date,
    pollution_renewal_date,
    mv_tax_date,
    counter_sign_renewal_date,
    passing_renewal_date,
    other_state_tax_renewal_date,
    permit_renewal_date,
    dvr_status,
    medical_box,
    camera1_status,
    camera2_status,
    camera3_status,
    fire_equipment,
    seat_belt,
    challan_if_any,
    route_chart,
    reflector_sticker,
    seat_cover,
    ac,
    gps,
    batches_whistle,
    service,
    washing,
    todays_reading,
    greasing,
    brake_check,
    wheel_alignment,
    check_all_glasses,
    lights_and_reflectors,
    tyre,
    air_check,
  } = req.body;

  try {
    const { rows } = await pool.query(
      `UPDATE vehicle_checklist SET
         date = $1, vehicle_name = $2, driver_name = $3, driving_license_renewal_date = $4, vehicle_rc = $5,
         insurance_renewal_date = $6, pollution_renewal_date = $7, mv_tax_date = $8, counter_sign_renewal_date = $9,
         passing_renewal_date = $10, other_state_tax_renewal_date = $11, permit_renewal_date = $12, dvr_status = $13,
         medical_box = $14, camera1_status = $15, camera2_status = $16, camera3_status = $17, fire_equipment = $18,
         seat_belt = $19, challan_if_any = $20, route_chart = $21, reflector_sticker = $22, seat_cover = $23,
         ac = $24, gps = $25, batches_whistle = $26, service = $27, washing = $28, todays_reading = $29,
         greasing = $30, brake_check = $31, wheel_alignment = $32, check_all_glasses = $33, lights_and_reflectors = $34,
         tyre = $35, air_check = $36 WHERE id = $37 RETURNING *`,
      [
        date,
        vehicle_name,
        driver_name,
        driving_license_renewal_date,
        vehicle_rc,
        insurance_renewal_date,
        pollution_renewal_date,
        mv_tax_date,
        counter_sign_renewal_date,
        passing_renewal_date,
        other_state_tax_renewal_date,
        permit_renewal_date,
        dvr_status,
        medical_box,
        camera1_status,
        camera2_status,
        camera3_status,
        fire_equipment,
        seat_belt,
        challan_if_any,
        route_chart,
        reflector_sticker,
        seat_cover,
        ac,
        gps,
        batches_whistle,
        service,
        washing,
        todays_reading,
        greasing,
        brake_check,
        wheel_alignment,
        check_all_glasses,
        lights_and_reflectors,
        tyre,
        air_check,
        id,
      ]
    );
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Vehicle checklist not found' });
    }
  } catch (err) {
    console.error('Error updating vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to update vehicle checklist' });
  }
});

// DELETE a vehicle checklist
app.delete('/vehicle-checklist/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const { rowCount } = await pool.query('DELETE FROM vehicle_checklist WHERE id = $1', [id]);
    if (rowCount > 0) {
      res.json({ message: 'Vehicle checklist deleted successfully' });
    } else {
      res.status(404).json({ error: 'Vehicle checklist not found' });
    }
  } catch (err) {
    console.error('Error deleting vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to delete vehicle checklist' });
  }
});

app.get('/student-list', async (req, res) => {
  const page = parseInt(req.query.page) || 0;
  const size = parseInt(req.query.size) || 20;
  const offset = page * size;

  try {
    const result = await pool.query('SELECT * FROM student_list LIMIT $1 OFFSET $2', [size, offset]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

app.get('/student-details', async (req, res) => {
  const page = parseInt(req.query.page) || 0;
  const size = parseInt(req.query.size) || 20;
  const offset = page * size;

  try {
    const result = await pool.query('SELECT * FROM student_list LIMIT $1 OFFSET $2', [size, offset]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

app.get('/certificates', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT c.*, s.student_name
      FROM certificates c
      JOIN student_list s ON c.student_id = s.serial_no
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching certificates:', err);
    res.status(500).json({ message: 'Failed to fetch certificates. Please try again.' });
  }
});

app.post('/certificates', async (req, res) => {
  const { student_id, certificate_type, issue_date, status, issued_by } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO certificates (student_id, certificate_type, issue_date, status, issued_by) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [student_id, certificate_type, issue_date, status, issued_by]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating certificate:', err);
    res.status(500).json({ message: 'Failed to create certificate. Please try again.' });
  }
});

app.put('/certificates/:id', async (req, res) => {
  const { certificate_type, issue_date, status, issued_by } = req.body;

  try {
    const result = await pool.query(
      'UPDATE certificates SET certificate_type = $1, issue_date = $2, status = $3, issued_by = $4 WHERE certificate_id = $5 RETURNING *',
      [certificate_type, issue_date, status, issued_by, req.params.id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating certificate:', err);
    res.status(500).json({ message: 'Failed to update certificate. Please try again.' });
  }
});

app.get('/product-units', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM product_unit');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching product units:', err);
    res.status(500).json({ message: 'Failed to fetch product units. Please try again.' });
  }
});

app.post('/product-units', async (req, res) => {
  const { unit_name } = req.body;
  try {
    const result = await pool.query('INSERT INTO product_unit (unit_name) VALUES ($1) RETURNING *', [unit_name]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating product unit:', err);
    res.status(500).json({ message: 'Failed to create product unit. Please try again.' });
  }
});

app.put('/product-units/:id', async (req, res) => {
  const { id } = req.params;
  const { unit_name } = req.body;
  try {
    const result = await pool.query('UPDATE product_unit SET unit_name = $1 WHERE unit_id = $2 RETURNING *', [unit_name, id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating product unit:', err);
    res.status(500).json({ message: 'Failed to update product unit. Please try again.' });
  }
});

app.delete('/product-units/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM product_unit WHERE unit_id = $1', [id]);
    res.status(200).json({ message: 'Product unit deleted successfully' });
  } catch (err) {
    console.error('Error deleting product unit:', err);
    res.status(500).json({ message: 'Failed to delete product unit. Please try again.' });
  }
});

app.get('/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM product_list');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ message: 'Failed to fetch products. Please try again.' });
  }
});

app.post('/products', async (req, res) => {
  const { product_name, quantity, product_unit, product_code, description, vendor_name, vendor_price, discount } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO product_list (product_name, quantity, product_unit, product_code, description, vendor_name, vendor_price, discount) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
      [product_name, quantity, product_unit, product_code, description, vendor_name, vendor_price, discount]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating product:', err);
    res.status(500).json({ message: 'Failed to create product. Please try again.' });
  }
});

app.put('/products/:id', async (req, res) => {
  const { id } = req.params;
  const { product_name, quantity, product_unit, product_code, description, vendor_name, vendor_price, discount } = req.body;
  try {
    const result = await pool.query(
      'UPDATE product_list SET product_name = $1, quantity = $2, product_unit = $3, product_code = $4, description = $5, vendor_name = $6, vendor_price = $7, discount = $8 WHERE product_id = $9 RETURNING *',
      [product_name, quantity, product_unit, product_code, description, vendor_name, vendor_price, discount, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating product:', err);
    res.status(500).json({ message: 'Failed to update product. Please try again.' });
  }
});

app.delete('/products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM product_list WHERE product_id = $1', [id]);
    res.status(200).json({ message: 'Product deleted successfully' });
  } catch (err) {
    console.error('Error deleting product:', err);
    res.status(500).json({ message: 'Failed to delete product. Please try again.' });
  }
});

app.get('/stock-categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stock_category');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching stock categories:', err);
    res.status(500).json({ message: 'Failed to fetch stock categories. Please try again.' });
  }
});

app.post('/stock-categories', async (req, res) => {
  const { category_name, stock_code, order_no } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO stock_category (category_name, stock_code, order_no) VALUES ($1, $2, $3) RETURNING *',
      [category_name, stock_code, order_no]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating stock category:', err);
    res.status(500).json({ message: 'Failed to create stock category. Please try again.' });
  }
});

app.put('/stock-categories/:id', async (req, res) => {
  const { id } = req.params;
  const { category_name, stock_code, order_no } = req.body;
  try {
    const result = await pool.query(
      'UPDATE stock_category SET category_name = $1, stock_code = $2, order_no = $3 WHERE category_id = $4 RETURNING *',
      [category_name, stock_code, order_no, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating stock category:', err);
    res.status(500).json({ message: 'Failed to update stock category. Please try again.' });
  }
});

app.delete('/stock-categories/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM stock_category WHERE category_id = $1', [id]);
    res.status(200).json({ message: 'Stock category deleted successfully' });
  } catch (err) {
    console.error('Error deleting stock category:', err);
    res.status(500).json({ message: 'Failed to delete stock category. Please try again.' });
  }
});

app.get('/stock-types', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stock_type');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching stock types:', err);
    res.status(500).json({ message: 'Failed to fetch stock types. Please try again.' });
  }
});

app.post('/stock-types', async (req, res) => {
  const { category_name, type_name, stock_code, order_no } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO stock_type (category_name, type_name, stock_code, order_no) VALUES ($1, $2, $3, $4) RETURNING *',
      [category_name, type_name, stock_code, order_no]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating stock type:', err);
    res.status(500).json({ message: 'Failed to create stock type. Please try again.' });
  }
});

app.put('/stock-types/:id', async (req, res) => {
  const { id } = req.params;
  const { category_name, type_name, stock_code, order_no } = req.body;
  try {
    const result = await pool.query(
      'UPDATE stock_type SET category_name = $1, type_name = $2, stock_code = $3, order_no = $4 WHERE type_id = $5 RETURNING *',
      [category_name, type_name, stock_code, order_no, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating stock type:', err);
    res.status(500).json({ message: 'Failed to update stock type. Please try again.' });
  }
});

app.delete('/stock-types/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM stock_type WHERE type_id = $1', [id]);
    res.status(200).json({ message: 'Stock type deleted successfully' });
  } catch (err) {
    console.error('Error deleting stock type:', err);
    res.status(500).json({ message: 'Failed to delete stock type. Please try again.' });
  }
});

app.get('/vendors', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vendor');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching vendors:', err);
    res.status(500).json({ message: 'Failed to fetch vendors. Please try again.' });
  }
});

app.post('/vendors', async (req, res) => {
  const { vendor_name, vendor_type, contact_name, phone_no, email, website, address } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO vendor (vendor_name, vendor_type, contact_name, phone_no, email, website, address) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [vendor_name, vendor_type, contact_name, phone_no, email, website, address]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating vendor:', err);
    res.status(500).json({ message: 'Failed to create vendor. Please try again.' });
  }
});

app.put('/vendors/:id', async (req, res) => {
  const { id } = req.params;
  const { vendor_name, vendor_type, contact_name, phone_no, email, website, address } = req.body;
  try {
    const result = await pool.query(
      'UPDATE vendor SET vendor_name = $1, vendor_type = $2, contact_name = $3, phone_no = $4, email = $5, website = $6, address = $7 WHERE vendor_id = $8 RETURNING *',
      [vendor_name, vendor_type, contact_name, phone_no, email, website, address, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating vendor:', err);
    res.status(500).json({ message: 'Failed to update vendor. Please try again.' });
  }
});

app.delete('/vendors/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM vendor WHERE vendor_id = $1', [id]);
    res.status(200).json({ message: 'Vendor deleted successfully' });
  } catch (err) {
    console.error('Error deleting vendor:', err);
    res.status(500).json({ message: 'Failed to delete vendor. Please try again.' });
  }
});

app.get('/issue-products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM issue_product');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching issue products:', err);
    res.status(500).json({ message: 'Failed to fetch issue products. Please try again.' });
  }
});

app.post('/issue-products', async (req, res) => {
  const { date, approver, issue_to, product, quantity, unit, description, approved_by, posted_by, posted_on, remarks } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO issue_product (date, approver, issue_to, product, quantity, unit, description, approved_by, posted_by, posted_on, remarks) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *',
      [date, approver, issue_to, product, quantity, unit, description, approved_by, posted_by, posted_on, remarks]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating issue product:', err);
    res.status(500).json({ message: 'Failed to create issue product. Please try again.' });
  }
});

app.get('/issue-products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM issue_product WHERE issue_id = $1', [id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching issue product:', err);
    res.status(500).json({ message: 'Failed to fetch issue product. Please try again.' });
  }
});

app.put('/issue-products/:id', async (req, res) => {
  const { id } = req.params;
  const { date, approver, issue_to, product, quantity, unit, description, approved_by, posted_by, posted_on, remarks } = req.body;
  try {
    const result = await pool.query(
      'UPDATE issue_product SET date = $1, approver = $2, issue_to = $3, product = $4, quantity = $5, unit = $6, description = $7, approved_by = $8, posted_by = $9, posted_on = $10, remarks = $11 WHERE issue_id = $12 RETURNING *',
      [date, approver, issue_to, product, quantity, unit, description, approved_by, posted_by, posted_on, remarks, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating issue product:', err);
    res.status(500).json({ message: 'Failed to update issue product. Please try again.' });
  }
});

app.delete('/issue-products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM issue_product WHERE issue_id = $1', [id]);
    res.status(200).json({ message: 'Issue product deleted successfully' });
  } catch (err) {
    console.error('Error deleting issue product:', err);
    res.status(500).json({ message: 'Failed to delete issue product. Please try again.' });
  }
});

app.get('/product-scrap', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM product_scrap');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching product scrap:', err);
    res.status(500).json({ message: 'Failed to fetch product scrap. Please try again.' });
  }
});

app.post('/product-scrap', async (req, res) => {
  const { category, type, product, scrap, quantity, scrap_date } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO product_scrap (category, type, product, scrap, quantity, scrap_date) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [category, type, product, scrap, quantity, scrap_date]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating product scrap:', err);
    res.status(500).json({ message: 'Failed to create product scrap. Please try again.' });
  }
});

app.put('/product-scrap/:id', async (req, res) => {
  const { id } = req.params;
  const { category, type, product, scrap, quantity, scrap_date } = req.body;
  try {
    const result = await pool.query(
      'UPDATE product_scrap SET category = $1, type = $2, product = $3, scrap = $4, quantity = $5, scrap_date = $6 WHERE scrap_id = $7 RETURNING *',
      [category, type, product, scrap, quantity, scrap_date, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating product scrap:', err);
    res.status(500).json({ message: 'Failed to update product scrap. Please try again.' });
  }
});

app.delete('/product-scrap/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM product_scrap WHERE scrap_id = $1', [id]);
    res.status(200).json({ message: 'Product scrap deleted successfully' });
  } catch (err) {
    console.error('Error deleting product scrap:', err);
    res.status(500).json({ message: 'Failed to delete product scrap. Please try again.' });
  }
});

// Fetch stock movements
app.get('/stock-movements', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stock_movement');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching stock movements:', err);
    res.status(500).json({ message: 'Failed to fetch stock movements. Please try again.' });
  }
});

// Create new stock movement
app.post('/stock-movements', async (req, res) => {
  const { transaction_type, order_number, date, product, quantity } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO stock_movement (transaction_type, order_number, date, product, quantity) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [transaction_type, order_number, date, product, quantity]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating stock movement:', err);
    res.status(500).json({ message: 'Failed to create stock movement. Please try again.' });
  }
});

app.get('/purchases', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM purchase_list');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching purchases:', err);
    res.status(500).json({ message: 'Failed to fetch purchases. Please try again.' });
  }
});

app.post('/purchases', async (req, res) => {
  const { purchase_no, branch, date, vendor, total_amount, gross_amount, net_amount, status, items } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO purchase_list (purchase_no, branch, date, vendor, total_amount, gross_amount, net_amount, status, items) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
      [purchase_no, branch, date, vendor, total_amount, gross_amount, net_amount, status, JSON.stringify(items)]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating purchase:', err);
    res.status(500).json({ message: 'Failed to create purchase. Please try again.' });
  }
});

app.put('/purchases/:id', async (req, res) => {
  const { id } = req.params;
  const { purchase_no, branch, date, vendor, total_amount, gross_amount, net_amount, status, items } = req.body;
  try {
    const result = await pool.query(
      'UPDATE purchase_list SET purchase_no = $1, branch = $2, date = $3, vendor = $4, total_amount = $5, gross_amount = $6, net_amount = $7, status = $8, items = $9 WHERE purchase_id = $10 RETURNING *',
      [purchase_no, branch, date, vendor, total_amount, gross_amount, net_amount, status, JSON.stringify(items), id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating purchase:', err);
    res.status(500).json({ message: 'Failed to update purchase. Please try again.' });
  }
});

app.delete('/purchases/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM purchase_list WHERE purchase_id = $1', [id]);
    res.status(200).json({ message: 'Purchase deleted successfully' });
  } catch (err) {
    console.error('Error deleting purchase:', err);
    res.status(500).json({ message: 'Failed to delete purchase. Please try again.' });
  }
});

// Fetch branches
app.get('/branches', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM branches');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching branches:', err);
    res.status(500).json({ message: 'Failed to fetch branches. Please try again.' });
  }
});

app.get('/orders', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM orders');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching orders:', err);
    res.status(500).json({ message: 'Failed to fetch orders. Please try again.' });
  }
});

app.put('/orders/:id/status', async (req, res) => {
  const { id } = req.params;
  const { status, reply } = req.body;
  try {
    const result = await pool.query(
      'UPDATE orders SET status = $1, reply = $2 WHERE id = $3 RETURNING *',
      [status, reply, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating order status:', err);
    res.status(500).json({ message: 'Failed to update order status. Please try again.' });
  }
});

app.get('/orders/:id/remarks', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM remarks WHERE order_id = $1', [id]);
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching remarks:', err);
    res.status(500).json({ message: 'Failed to fetch remarks. Please try again.' });
  }
});

app.get('/orders/:id/items', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM order_items WHERE order_id = $1', [id]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching order items:', err);
    res.status(500).json({ message: 'Failed to fetch order items. Please try again.' });
  }
});

// Fetch all reminders
app.get('/reminders', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reminders');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching reminders:', err);
    res.status(500).json({ message: 'Failed to fetch reminders. Please try again.' });
  }
});

// Create a new reminder
app.post('/reminders', async (req, res) => {
  const { name, email, phone, due_date, amount } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO reminders (name, email, phone, due_date, amount) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, email, phone, due_date, amount]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating reminder:', err);
    res.status(500).json({ message: 'Failed to create reminder. Please try again.' });
  }
});

// Edit a reminder
app.put('/reminders/:id', async (req, res) => {
  const { id } = req.params;
  const { name, email, phone, due_date, amount } = req.body;
  try {
    const result = await pool.query(
      'UPDATE reminders SET name = $1, email = $2, phone = $3, due_date = $4, amount = $5 WHERE id = $6 RETURNING *',
      [name, email, phone, due_date, amount, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating reminder:', err);
    res.status(500).json({ message: 'Failed to update reminder. Please try again.' });
  }
});

// Delete a reminder
app.delete('/reminders/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM reminders WHERE id = $1', [id]);
    res.status(200).json({ message: 'Reminder deleted successfully' });
  } catch (err) {
    console.error('Error deleting reminder:', err);
    res.status(500).json({ message: 'Failed to delete reminder. Please try again.' });
  }
});

app.get('/subjects', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM subject_master ORDER BY order_no');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching subjects:', err);
    res.status(500).json({ message: 'Failed to fetch subjects. Please try again.' });
  }
});

app.post('/subjects', async (req, res) => {
  const { subject_name, subject_short_name, order_no, color_code } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO subject_master (subject_name, subject_short_name, order_no, color_code) VALUES ($1, $2, $3, $4) RETURNING *',
      [subject_name, subject_short_name, order_no, color_code]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating subject:', err);
    res.status(500).json({ message: 'Failed to create subject. Please try again.' });
  }
});

app.put('/subjects/:id', async (req, res) => {
  const { id } = req.params;
  const { subject_name, subject_short_name, order_no, color_code } = req.body;
  try {
    const result = await pool.query(
      'UPDATE subject_master SET subject_name = $1, subject_short_name = $2, order_no = $3, color_code = $4 WHERE id = $5 RETURNING *',
      [subject_name, subject_short_name, order_no, color_code, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating subject:', err);
    res.status(500).json({ message: 'Failed to update subject. Please try again.' });
  }
});

app.delete('/subjects/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM subject_master WHERE id = $1', [id]);
    res.status(200).json({ message: 'Subject deleted successfully' });
  } catch (err) {
    console.error('Error deleting subject:', err);
    res.status(500).json({ message: 'Failed to delete subject. Please try again.' });
  }
});

// Fetch all syllabi
app.get('/syllabi', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM syllabus');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching syllabi:', err);
    res.status(500).json({ message: 'Failed to fetch syllabi. Please try again.' });
  }
});

// Create new syllabus
app.post('/syllabi', async (req, res) => {
  const { class: className, subject, syllabus } = req.body;
  try {
    const values = syllabus.map(({ topic, start_date, end_date }) => `('${className}', '${subject}', '${topic}', '${start_date}', '${end_date}')`).join(',');
    const result = await pool.query(`INSERT INTO syllabus (class, subject, topic, start_date, end_date) VALUES ${values} RETURNING *`);
    res.status(201).json(result.rows);
  } catch (err) {
    console.error('Error creating syllabus:', err);
    res.status(500).json({ message: 'Failed to create syllabus. Please try again.' });
  }
});

// Edit syllabus
app.put('/syllabi/:id', async (req, res) => {
  const { id } = req.params;
  const { class: className, subject, topic, start_date, end_date } = req.body;
  try {
    const result = await pool.query(
      'UPDATE syllabus SET class = $1, subject = $2, topic = $3, start_date = $4, end_date = $5 WHERE id = $6 RETURNING *',
      [className, subject, topic, start_date, end_date, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating syllabus:', err);
    res.status(500).json({ message: 'Failed to update syllabus. Please try again.' });
  }
});

// Delete syllabus
app.delete('/syllabi/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM syllabus WHERE id = $1', [id]);
    res.status(200).json({ message: 'Syllabus deleted successfully' });
  } catch (err) {
    console.error('Error deleting syllabus:', err);
    res.status(500).json({ message: 'Failed to delete syllabus. Please try again.' });
  }
});

// Fetch all assigned subjects
app.get('/assigned-subjects', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM assigned_subjects');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching assigned subjects:', err);
    res.status(500).json({ message: 'Failed to fetch assigned subjects. Please try again.' });
  }
});

// Fetch all students
app.get('/student-directory', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM student_list');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

// Fetch all assigned subjects
app.get('/assigned-subjects', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        a.id,
        a.student_id,
        a.subject_id,
        s.student_name,
        s.class_section,
        sub.subject_name
      FROM
        assigned_subjects a
      JOIN
        student_list s ON a.student_id = s.serial_no
      JOIN
        subject_master sub ON a.subject_id = sub.id
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching assigned subjects:', err);
    res.status(500).json({ message: 'Failed to fetch assigned subjects. Please try again.' });
  }
});

// Fetch all students
app.get('/student-directory', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM student_list');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

// Assign a subject to a student
app.post('/assigned-subjects', async (req, res) => {
  const { student_id, subject_id } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO assigned_subjects (student_id, subject_id) VALUES ($1, $2) RETURNING *',
      [student_id, subject_id]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error assigning subject:', err);
    res.status(500).json({ message: 'Failed to assign subject. Please try again.' });
  }
});

// Edit an assigned subject
app.put('/assigned-subjects/:id', async (req, res) => {
  const { id } = req.params;
  const { student_id, subject_id } = req.body;
  try {
    const result = await pool.query(
      'UPDATE assigned_subjects SET student_id = $1, subject_id = $2 WHERE id = $3 RETURNING *',
      [student_id, subject_id, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing assignment:', err);
    res.status(500).json({ message: 'Failed to edit assignment. Please try again.' });
  }
});

// Delete an assigned subject
app.delete('/assigned-subjects/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM assigned_subjects WHERE id = $1', [id]);
    res.status(200).json({ message: 'Assignment deleted successfully' });
  } catch (err) {
    console.error('Error deleting assignment:', err);
    res.status(500).json({ message: 'Failed to delete assignment. Please try again.' });
  }
});

// Get all classes
app.get('/classes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM class_master');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching classes:', err);
    res.status(500).json({ message: 'Failed to fetch classes' });
  }
});

// Create a new class
app.post('/classes', async (req, res) => {
  const { class_name, class_in_words, promoted_class, promoted_class_in_words, order_no, session } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO class_master (class_name, class_in_words, promoted_class, promoted_class_in_words, order_no, session) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [class_name, class_in_words, promoted_class, promoted_class_in_words, order_no, session]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating class:', err);
    res.status(500).json({ message: 'Failed to create class' });
  }
});

// Update a class
app.put('/classes/:id', async (req, res) => {
  const { id } = req.params;
  const { class_name, class_in_words, promoted_class, promoted_class_in_words, order_no, session } = req.body;
  try {
    const result = await pool.query(
      'UPDATE class_master SET class_name = $1, class_in_words = $2, promoted_class = $3, promoted_class_in_words = $4, order_no = $5, session = $6 WHERE id = $7 RETURNING *',
      [class_name, class_in_words, promoted_class, promoted_class_in_words, order_no, session, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating class:', err);
    res.status(500).json({ message: 'Failed to update class' });
  }
});

// Delete a class
app.delete('/classes/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM class_master WHERE id = $1', [id]);
    res.status(200).json({ message: 'Class deleted successfully' });
  } catch (err) {
    console.error('Error deleting class:', err);
    res.status(500).json({ message: 'Failed to delete class' });
  }
});

// Fetch all coordinator assignments
app.get('/coordinator-assignments', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM coordinator_assignment');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching coordinator assignments:', err);
    res.status(500).json({ message: 'Failed to fetch coordinator assignments. Please try again.' });
  }
});

// Create a new coordinator assignment
app.post('/coordinator-assignments', async (req, res) => {
  const { staff_name, class_section } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO coordinator_assignment (staff_name, class_section) VALUES ($1, $2) RETURNING *',
      [staff_name, class_section]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating coordinator assignment:', err);
    res.status(500).json({ message: 'Failed to create coordinator assignment. Please try again.' });
  }
});

// Update a coordinator assignment
app.put('/coordinator-assignments/:id', async (req, res) => {
  const { id } = req.params;
  const { staff_name, class_section } = req.body;
  try {
    const result = await pool.query(
      'UPDATE coordinator_assignment SET staff_name = $1, class_section = $2 WHERE id = $3 RETURNING *',
      [staff_name, class_section, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating coordinator assignment:', err);
    res.status(500).json({ message: 'Failed to update coordinator assignment. Please try again.' });
  }
});

// Delete a coordinator assignment
app.delete('/coordinator-assignments/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM coordinator_assignment WHERE id = $1', [id]);
    res.status(200).json({ message: 'Coordinator assignment deleted successfully' });
  } catch (err) {
    console.error('Error deleting coordinator assignment:', err);
    res.status(500).json({ message: 'Failed to delete coordinator assignment. Please try again.' });
  }
});

// Get all sections
app.get('/sections', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM section_master ORDER BY order_no');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching sections:', err);
    res.status(500).json({ message: 'Failed to fetch sections. Please try again.' });
  }
});

// Add new section
app.post('/sections', async (req, res) => {
  const { section_name, order_no, session } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO section_master (section_name, order_no, session) VALUES ($1, $2, $3) RETURNING *',
      [section_name, order_no, session]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding section:', err);
    res.status(500).json({ message: 'Failed to add section. Please try again.' });
  }
});

// Edit section
app.put('/sections/:id', async (req, res) => {
  const { id } = req.params;
  const { section_name, order_no, session } = req.body;
  try {
    const result = await pool.query(
      'UPDATE section_master SET section_name = $1, order_no = $2, session = $3 WHERE id = $4 RETURNING *',
      [section_name, order_no, session, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating section:', err);
    res.status(500).json({ message: 'Failed to update section. Please try again.' });
  }
});

// Delete section
app.delete('/sections/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM section_master WHERE id = $1', [id]);
    res.status(200).json({ message: 'Section deleted successfully' });
  } catch (err) {
    console.error('Error deleting section:', err);
    res.status(500).json({ message: 'Failed to delete section. Please try again.' });
  }
});

// Get all assigned classes
app.get('/assigned-classes', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT ac.id, cm.class_name, sm.section_name, ac.teacher_name, ac.class_capacity, ac.report_template_type
      FROM assigned_classes ac
      JOIN class_master cm ON ac.class_id = cm.id
      JOIN section_master sm ON ac.section_id = sm.id
      ORDER BY cm.order_no, sm.order_no
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching assigned classes:', err);
    res.status(500).json({ message: 'Failed to fetch assigned classes. Please try again.' });
  }
});

// Add new assigned class
app.post('/assigned-classes', async (req, res) => {
  const { class_id, section_id, teacher_name, class_capacity, report_template_type } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO assigned_classes (class_id, section_id, teacher_name, class_capacity, report_template_type) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [class_id, section_id, teacher_name, class_capacity, report_template_type]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding assigned class:', err);
    res.status(500).json({ message: 'Failed to add assigned class. Please try again.' });
  }
});

// Edit assigned class
app.put('/assigned-classes/:id', async (req, res) => {
  const { id } = req.params;
  const { class_id, section_id, teacher_name, class_capacity, report_template_type } = req.body;
  try {
    const result = await pool.query(
      'UPDATE assigned_classes SET class_id = $1, section_id = $2, teacher_name = $3, class_capacity = $4, report_template_type = $5 WHERE id = $6 RETURNING *',
      [class_id, section_id, teacher_name, class_capacity, report_template_type, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating assigned class:', err);
    res.status(500).json({ message: 'Failed to update assigned class. Please try again.' });
  }
});

// Delete assigned class
app.delete('/assigned-classes/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM assigned_classes WHERE id = $1', [id]);
    res.status(200).json({ message: 'Assigned class deleted successfully' });
  } catch (err) {
    console.error('Error deleting assigned class:', err);
    res.status(500).json({ message: 'Failed to delete assigned class. Please try again.' });
  }
});

// Get all departments
app.get('/departments', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM department_master ORDER BY order_no');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching departments:', err);
    res.status(500).send("Server Error");
  }
});

// Create a new department
app.post('/departments', async (req, res) => {
  const { department_name, order_no } = req.body;
  try {
    const newDept = await pool.query(
      'INSERT INTO department_master (department_name, order_no) VALUES ($1, $2) RETURNING *',
      [department_name, order_no]
    );
    res.status(201).json(newDept.rows[0]);
  } catch (err) {
    console.error('Error creating department:', err);
    res.status(500).send("Server Error");
  }
});

// Update a department
app.put('/departments/:id', async (req, res) => {
  const { id } = req.params;
  const { department_name, order_no } = req.body;
  try {
    const updatedDept = await pool.query(
      'UPDATE department_master SET department_name = $1, order_no = $2 WHERE id = $3 RETURNING *',
      [department_name, order_no, id]
    );
    res.json(updatedDept.rows[0]);
  } catch (err) {
    console.error('Error updating department:', err);
    res.status(500).send("Server Error");
  }
});

// Delete a department
app.delete('/departments/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM department_master WHERE id = $1', [id]);
    res.json({ message: "Department deleted successfully" });
  } catch (err) {
    console.error('Error deleting department:', err);
    res.status(500).send("Server Error");
  }
});

// Get all designations
app.get('/designations', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT d.id, d.designation_name, d.order_no, dm.department_name ' +
      'FROM designation_master d ' +
      'JOIN department_master dm ON d.department_id = dm.id ' +
      'ORDER BY d.order_no'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching designations:', err);
    res.status(500).send("Server Error");
  }
});

// Create a new designation
app.post('/designations', async (req, res) => {
  const { department_id, designation_name, order_no } = req.body;
  try {
    const newDesignation = await pool.query(
      'INSERT INTO designation_master (department_id, designation_name, order_no) VALUES ($1, $2, $3) RETURNING *',
      [department_id, designation_name, order_no]
    );
    res.status(201).json(newDesignation.rows[0]);
  } catch (err) {
    console.error('Error creating designation:', err);
    res.status(500).send("Server Error");
  }
});

// Update a designation
app.put('/designations/:id', async (req, res) => {
  const { id } = req.params;
  const { department_id, designation_name, order_no } = req.body;
  try {
    const updatedDesignation = await pool.query(
      'UPDATE designation_master SET department_id = $1, designation_name = $2, order_no = $3 WHERE id = $4 RETURNING *',
      [department_id, designation_name, order_no, id]
    );
    res.json(updatedDesignation.rows[0]);
  } catch (err) {
    console.error('Error updating designation:', err);
    res.status(500).send("Server Error");
  }
});

// Delete a designation
app.delete('/designations/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM designation_master WHERE id = $1', [id]);
    res.json({ message: "Designation deleted successfully" });
  } catch (err) {
    console.error('Error deleting designation:', err);
    res.status(500).send("Server Error");
  }
});

// Get all staff categories
app.get('/staff-categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM staff_category_master ORDER BY order_no');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching staff categories:', err);
    res.status(500).send("Server Error");
  }
});

// Create a new staff category
app.post('/staff-categories', async (req, res) => {
  const { staff_category_name, order_no } = req.body;
  try {
    const newCategory = await pool.query(
      'INSERT INTO staff_category_master (staff_category_name, order_no) VALUES ($1, $2) RETURNING *',
      [staff_category_name, order_no]
    );
    res.status(201).json(newCategory.rows[0]);
  } catch (err) {
    console.error('Error creating staff category:', err);
    res.status(500).send("Server Error");
  }
});

// Update a staff category
app.put('/staff-categories/:id', async (req, res) => {
  const { id } = req.params;
  const { staff_category_name, order_no } = req.body;
  try {
    const updatedCategory = await pool.query(
      'UPDATE staff_category_master SET staff_category_name = $1, order_no = $2 WHERE id = $3 RETURNING *',
      [staff_category_name, order_no, id]
    );
    res.json(updatedCategory.rows[0]);
  } catch (err) {
    console.error('Error updating staff category:', err);
    res.status(500).send("Server Error");
  }
});

// Delete a staff category
app.delete('/staff-categories/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM staff_category_master WHERE id = $1', [id]);
    res.json({ message: "Staff category deleted successfully" });
  } catch (err) {
    console.error('Error deleting staff category:', err);
    res.status(500).send("Server Error");
  }
});

// Get all staff
app.get('/staff', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM staff_list ORDER BY id');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new staff
app.post('/staff', async (req, res) => {
    try {
        const {
            title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage,
            father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience,
            date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation
        } = req.body;

        const newStaff = await pool.query(
            'INSERT INTO staff_list (title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage, father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience, date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22) RETURNING *',
            [
                title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage,
                father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience,
                date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation
            ]
        );
        res.json(newStaff.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update a staff
app.put('/staff/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const {
            title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage,
            father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience,
            date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation
        } = req.body;

        const updatedStaff = await pool.query(
            'UPDATE staff_list SET title = $1, name = $2, education = $3, date_of_birth = $4, blood_group = $5, gender = $6, religion = $7, marital_status = $8, date_of_marriage = $9, father_husband_name = $10, is_teaching_employee = $11, identity_proof_type = $12, emergency_contact_no = $13, working_experience = $14, date_of_joining = $15, aadhar_card_no = $16, pan_card_no = $17, branch = $18, mobile_no = $19, email = $20, address = $21, department = $22, designation = $23 WHERE id = $24 RETURNING *',
            [
                title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage,
                father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience,
                date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation,
                id
            ]
        );
        res.json(updatedStaff.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete a staff
app.delete('/staff/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM staff_list WHERE id = $1', [id]);
        res.json({ message: "Staff deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Bulk upload staff
app.post('/staff/bulk-upload', async (req, res) => {
    if (!req.files || Object.keys(req.files).length === 0) {
        return res.status(400).send('No files were uploaded.');
    }

    let csvFile = req.files.file;
    let results = [];

    csvFile.data
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', async () => {
            for (const row of results) {
                const {
                    title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage,
                    father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience,
                    date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation
                } = row;

                await pool.query(
                    'INSERT INTO staff_list (title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage, father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience, date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)',
                    [
                        title, name, education, date_of_birth, blood_group, gender, religion, marital_status, date_of_marriage,
                        father_husband_name, is_teaching_employee, identity_proof_type, emergency_contact_no, working_experience,
                        date_of_joining, aadhar_card_no, pan_card_no, branch, mobile_no, email, address, department, designation
                    ]
                );
            }
            res.send('Bulk upload completed.');
        });
});

// Bulk upload staff images
app.post('/staff/bulk-upload-images', async (req, res) => {
    if (!req.files || Object.keys(req.files).length === 0) {
        return res.status(400).send('No files were uploaded.');
    }

    let zipFile = req.files.file;
    const uploadPath = __dirname + '/uploads/';

    zipFile.mv(uploadPath + zipFile.name, async (err) => {
        if (err) return res.status(500).send(err);

        fs.createReadStream(uploadPath + zipFile.name)
            .pipe(unzipper.Extract({ path: uploadPath }))
            .on('close', () => {
                fs.unlinkSync(uploadPath + zipFile.name);
                res.send('Bulk image upload completed.');
            });
    });
});

// Get all released staff
app.get('/released-staff', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM released_staff_list ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Create a new released staff
app.post('/released-staff', async (req, res) => {
  try {
    const { name, employee_no, mobile_no, email, address, is_teaching, department, designation } = req.body;
    const newStaff = await pool.query(
      'INSERT INTO released_staff_list (name, employee_no, mobile_no, email, address, is_teaching, department, designation) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
      [name, employee_no, mobile_no, email, address, is_teaching, department, designation]
    );
    res.json(newStaff.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Update a released staff
app.put('/released-staff/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, employee_no, mobile_no, email, address, is_teaching, department, designation } = req.body;
    const updatedStaff = await pool.query(
      'UPDATE released_staff_list SET name = $1, employee_no = $2, mobile_no = $3, email = $4, address = $5, is_teaching = $6, department = $7, designation = $8 WHERE id = $9 RETURNING *',
      [name, employee_no, mobile_no, email, address, is_teaching, department, designation, id]
    );
    res.json(updatedStaff.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Delete a released staff
app.delete('/released-staff/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM released_staff_list WHERE id = $1', [id]);
    res.json({ message: "Released staff deleted successfully" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

app.get('/vehicles', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vehicles');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Endpoint to add a vehicle report
app.post('/vehicle_reports', async (req, res) => {
  const { vehicle_id, report_date, issues, status } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO vehicle_reports (vehicle_id, report_date, issues, status) VALUES ($1, $2, $3, $4) RETURNING *',
      [vehicle_id, report_date, issues, status]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Endpoint to add fueling details
app.post('/fueling_details', async (req, res) => {
  const { vehicle_id, fuel_date, fuel_amount, cost } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO fueling_details (vehicle_id, fuel_date, fuel_amount, cost) VALUES ($1, $2, $3, $4) RETURNING *',
      [vehicle_id, fuel_date, fuel_amount, cost]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Endpoint to add daily meter readings
app.post('/daily_meter_readings', async (req, res) => {
  const { vehicle_id, reading_date, start_meter, end_meter } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO daily_meter_readings (vehicle_id, reading_date, start_meter, end_meter) VALUES ($1, $2, $3, $4) RETURNING *',
      [vehicle_id, reading_date, start_meter, end_meter]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Route to get all routes
app.get('/routes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM route_master');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to add a new route
app.post('/routes', async (req, res) => {
  const { route_name, start_location, end_location, stops } = req.body;

  try {
    const query = `
      INSERT INTO route_master (route_name, start_location, end_location, stops)
      VALUES ($1, $2, $3, $4) RETURNING *`;
    const values = [route_name, start_location, end_location, stops];
    const result = await pool.query(query, values);

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to get all vehicles
app.get('/vehicles', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vehicle_master');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

//// Route to add a new vehicle
//app.post('/vehicles', async (req, res) => {
//  const { vehicle_name, vehicle_number, capacity, route_id } = req.body;
//
//  try {
//    const query = `
//      INSERT INTO vehicle_master (vehicle_name, vehicle_number, capacity, route_id)
//      VALUES ($1, $2, $3, $4) RETURNING *`;
//    const values = [vehicle_name, vehicle_number, capacity, route_id];
//    const result = await pool.query(query, values);
//
//    res.status(201).json(result.rows[0]);
//  } catch (err) {
//    console.error(err);
//    res.status(500).json({ error: 'Internal Server Error' });
//  }
//});

// Route to get all petrol pumps
app.get('/petrol-pumps', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM petrol_pump_master');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Handle form submission
app.post('/submit', async (req, res) => {
  const { requestType, startDate, pickupAddress, dropAddress, mobileNumber, fillingPerson, remarks } = req.body;

  try {
    await pool.query(
      'INSERT INTO transport_requests (request_type, start_date, pickup_address, drop_address, mobile_number, filling_person, remarks) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [requestType, startDate, pickupAddress, dropAddress, mobileNumber, fillingPerson, remarks]
    );
    res.status(200).send('Request submitted successfully!');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error saving request to database.');
  }
});

// Dashboard to display requests
app.get('/dashboard', async (req, res) => {
  try {
    const result = await pool.query('SELECT start_date, request_type, pickup_address, drop_address, remarks FROM transport_requests');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error retrieving requests from database.');
  }
});

// Get all insurance details
app.get('/insurance', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vehicle_insurance');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Add a new insurance detail
app.post('/insurance', async (req, res) => {
  const { vehicle_name, start_date, end_date, amount } = req.body;
  try {
    await pool.query(
      'INSERT INTO vehicle_insurance (vehicle_name, start_date, end_date, amount) VALUES ($1, $2, $3, $4)',
      [vehicle_name, start_date, end_date, amount]
    );
    res.status(201).send('Insurance detail added');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Update an insurance detail
app.put('/insurance/:id', async (req, res) => {
  const { id } = req.params;
  const { vehicle_name, start_date, end_date, amount } = req.body;
  try {
    await pool.query(
      'UPDATE vehicle_insurance SET vehicle_name = $1, start_date = $2, end_date = $3, amount = $4 WHERE id = $5',
      [vehicle_name, start_date, end_date, amount, id]
    );
    res.status(200).send('Insurance detail updated');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Delete an insurance detail
app.delete('/insurance/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM vehicle_insurance WHERE id = $1', [id]);
    res.status(200).send('Insurance detail deleted');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Get all student transport details
app.get('/students_transport', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM student_transport');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Add a new student transport detail
app.post('/students_add', async (req, res) => {
  const {
    serial_number,
    student_name,
    admission_number,
    class: student_class,
    mobile_number,
    address,
    route,
    vehicle,
    bus_stop,
    transport_for
  } = req.body;
  try {
    await pool.query(
      'INSERT INTO student_transport (serial_number, student_name, admission_number, class, mobile_number, address, route, vehicle, bus_stop, transport_for) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)',
      [serial_number, student_name, admission_number, student_class, mobile_number, address, route, vehicle, bus_stop, transport_for]
    );
    res.status(201).send('Student transport detail added');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Update a student transport detail
app.put('/students_tp/:id', async (req, res) => {
  const { id } = req.params;
  const {
    serial_number,
    student_name,
    admission_number,
    class: student_class,
    mobile_number,
    address,
    route,
    vehicle,
    bus_stop,
    transport_for
  } = req.body;
  try {
    await pool.query(
      'UPDATE student_transport SET serial_number = $1, student_name = $2, admission_number = $3, class = $4, mobile_number = $5, address = $6, route = $7, vehicle = $8, bus_stop = $9, transport_for = $10 WHERE id = $11',
      [serial_number, student_name, admission_number, student_class, mobile_number, address, route, vehicle, bus_stop, transport_for, id]
    );
    res.status(200).send('Student transport detail updated');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Delete a student transport detail
app.delete('/students_up/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM student_transport WHERE id = $1', [id]);
    res.status(200).send('Student transport detail deleted');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// GET all fuel fillings
app.get('/fuel-fillings', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM fuel_fillings ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error('Error fetching fuel fillings:', err);
    res.status(500).json({ error: 'Failed to fetch fuel fillings' });
  }
});

// GET a single fuel filling by ID
app.get('/fuel-fillings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query('SELECT * FROM fuel_fillings WHERE id = $1', [id]);
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Fuel filling not found' });
    }
  } catch (err) {
    console.error('Error fetching fuel filling:', err);
    res.status(500).json({ error: 'Failed to fetch fuel filling' });
  }
});

// POST a new fuel filling
app.post('/fuel-fillings', async (req, res) => {
  const { vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO fuel_fillings (vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error adding fuel filling:', err);
    res.status(500).json({ error: 'Failed to add fuel filling' });
  }
});

// PUT update an existing fuel filling
app.put('/fuel-fillings/:id', async (req, res) => {
  const { id } = req.params;
  const { vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE fuel_fillings SET vehicle_name = $1, fuel_filling_date = $2, meter_reading = $3, quantity = $4, fuel_price = $5, slip_number = $6 WHERE id = $7 RETURNING *',
      [vehicle_name, fuel_filling_date, meter_reading, quantity, fuel_price, slip_number, id]
    );
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Fuel filling not found' });
    }
  } catch (err) {
    console.error('Error updating fuel filling:', err);
    res.status(500).json({ error: 'Failed to update fuel filling' });
  }
});

// DELETE a fuel filling by ID
app.delete('/fuel-fillings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query('DELETE FROM fuel_fillings WHERE id = $1 RETURNING *', [id]);
    if (rows.length > 0) {
      res.json({ message: 'Fuel filling deleted successfully' });
    } else {
      res.status(404).json({ error: 'Fuel filling not found' });
    }
  } catch (err) {
    console.error('Error deleting fuel filling:', err);
    res.status(500).json({ error: 'Failed to delete fuel filling' });
  }
});


// GET all vehicle maintenance
app.get('/vehicle-maintenance', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM vehicle_maintenance ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error('Error fetching vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to fetch vehicle maintenance' });
  }
});

// GET all maintenance details for a specific maintenance entry
app.get('/maintenance-details/:maintenance_id', async (req, res) => {
  const { maintenance_id } = req.params;
  try {
    const { rows } = await pool.query('SELECT * FROM maintenance_details WHERE maintenance_id = $1 ORDER BY id', [maintenance_id]);
    res.json(rows);
  } catch (err) {
    console.error('Error fetching maintenance details:', err);
    res.status(500).json({ error: 'Failed to fetch maintenance details' });
  }
});

// POST a new vehicle maintenance
app.post('/vehicle-maintenance', async (req, res) => {
  const { vehicle_name, maintenance_date, maintenance_name, meter_reading, details } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO vehicle_maintenance (vehicle_name, maintenance_date, maintenance_name, meter_reading) VALUES ($1, $2, $3, $4) RETURNING *',
      [vehicle_name, maintenance_date, maintenance_name, meter_reading]
    );
    const maintenanceId = rows[0].id;

    for (const detail of details) {
      await pool.query(
        'INSERT INTO maintenance_details (maintenance_id, date, bill_number, vendor_name, amount) VALUES ($1, $2, $3, $4, $5)',
        [maintenanceId, detail.date, detail.bill_number, detail.vendor_name, detail.amount]
      );
    }

    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error adding vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to add vehicle maintenance' });
  }
});

// PUT update an existing vehicle maintenance
app.put('/vehicle-maintenance/:id', async (req, res) => {
  const { id } = req.params;
  const { vehicle_name, maintenance_date, maintenance_name, meter_reading, details } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE vehicle_maintenance SET vehicle_name = $1, maintenance_date = $2, maintenance_name = $3, meter_reading = $4 WHERE id = $5 RETURNING *',
      [vehicle_name, maintenance_date, maintenance_name, meter_reading, id]
    );

    if (rows.length > 0) {
      await pool.query('DELETE FROM maintenance_details WHERE maintenance_id = $1', [id]);
      for (const detail of details) {
        await pool.query(
          'INSERT INTO maintenance_details (maintenance_id, date, bill_number, vendor_name, amount) VALUES ($1, $2, $3, $4, $5)',
          [id, detail.date, detail.bill_number, detail.vendor_name, detail.amount]
        );
      }
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Vehicle maintenance not found' });
    }
  } catch (err) {
    console.error('Error updating vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to update vehicle maintenance' });
  }
});

// DELETE a vehicle maintenance entry
app.delete('/vehicle-maintenance/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rowCount } = await pool.query('DELETE FROM vehicle_maintenance WHERE id = $1', [id]);
    if (rowCount > 0) {
      res.status(204).send();
    } else {
      res.status(404).json({ error: 'Vehicle maintenance not found' });
    }
  } catch (err) {
    console.error('Error deleting vehicle maintenance:', err);
    res.status(500).json({ error: 'Failed to delete vehicle maintenance' });
  }
});

// GET all vehicle checklists
app.get('/vehicle-checklist', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM vehicle_checklist ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error('Error fetching vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to fetch vehicle checklist' });
  }
});

// GET a single vehicle checklist by ID
app.get('/vehicle-checklist/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query('SELECT * FROM vehicle_checklist WHERE id = $1', [id]);
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Vehicle checklist not found' });
    }
  } catch (err) {
    console.error('Error fetching vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to fetch vehicle checklist' });
  }
});

// POST a new vehicle checklist
app.post('/vehicle-checklist', async (req, res) => {
  const {
    date,
    vehicle_name,
    driver_name,
    driving_license_renewal_date,
    vehicle_rc,
    insurance_renewal_date,
    pollution_renewal_date,
    mv_tax_date,
    counter_sign_renewal_date,
    passing_renewal_date,
    other_state_tax_renewal_date,
    permit_renewal_date,
    dvr_status,
    medical_box,
    camera1_status,
    camera2_status,
    camera3_status,
    fire_equipment,
    seat_belt,
    challan_if_any,
    route_chart,
    reflector_sticker,
    seat_cover,
    ac,
    gps,
    batches_whistle,
    service,
    washing,
    todays_reading,
    greasing,
    brake_check,
    wheel_alignment,
    check_all_glasses,
    lights_and_reflectors,
    tyre,
    air_check,
  } = req.body;

  try {
    const { rows } = await pool.query(
      `INSERT INTO vehicle_checklist (
         date, vehicle_name, driver_name, driving_license_renewal_date, vehicle_rc,
         insurance_renewal_date, pollution_renewal_date, mv_tax_date, counter_sign_renewal_date,
         passing_renewal_date, other_state_tax_renewal_date, permit_renewal_date, dvr_status,
         medical_box, camera1_status, camera2_status, camera3_status, fire_equipment, seat_belt,
         challan_if_any, route_chart, reflector_sticker, seat_cover, ac, gps, batches_whistle,
         service, washing, todays_reading, greasing, brake_check, wheel_alignment, check_all_glasses,
         lights_and_reflectors, tyre, air_check
       ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35)
       RETURNING *`,
      [
        date,
        vehicle_name,
        driver_name,
        driving_license_renewal_date,
        vehicle_rc,
        insurance_renewal_date,
        pollution_renewal_date,
        mv_tax_date,
        counter_sign_renewal_date,
        passing_renewal_date,
        other_state_tax_renewal_date,
        permit_renewal_date,
        dvr_status,
        medical_box,
        camera1_status,
        camera2_status,
        camera3_status,
        fire_equipment,
        seat_belt,
        challan_if_any,
        route_chart,
        reflector_sticker,
        seat_cover,
        ac,
        gps,
        batches_whistle,
        service,
        washing,
        todays_reading,
        greasing,
        brake_check,
        wheel_alignment,
        check_all_glasses,
        lights_and_reflectors,
        tyre,
        air_check,
      ]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error adding vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to add vehicle checklist' });
  }
});

// PUT update an existing vehicle checklist
app.put('/vehicle-checklist/:id', async (req, res) => {
  const { id } = req.params;
  const {
    date,
    vehicle_name,
    driver_name,
    driving_license_renewal_date,
    vehicle_rc,
    insurance_renewal_date,
    pollution_renewal_date,
    mv_tax_date,
    counter_sign_renewal_date,
    passing_renewal_date,
    other_state_tax_renewal_date,
    permit_renewal_date,
    dvr_status,
    medical_box,
    camera1_status,
    camera2_status,
    camera3_status,
    fire_equipment,
    seat_belt,
    challan_if_any,
    route_chart,
    reflector_sticker,
    seat_cover,
    ac,
    gps,
    batches_whistle,
    service,
    washing,
    todays_reading,
    greasing,
    brake_check,
    wheel_alignment,
    check_all_glasses,
    lights_and_reflectors,
    tyre,
    air_check,
  } = req.body;

  try {
    const { rows } = await pool.query(
      `UPDATE vehicle_checklist SET
         date = $1, vehicle_name = $2, driver_name = $3, driving_license_renewal_date = $4, vehicle_rc = $5,
         insurance_renewal_date = $6, pollution_renewal_date = $7, mv_tax_date = $8, counter_sign_renewal_date = $9,
         passing_renewal_date = $10, other_state_tax_renewal_date = $11, permit_renewal_date = $12, dvr_status = $13,
         medical_box = $14, camera1_status = $15, camera2_status = $16, camera3_status = $17, fire_equipment = $18,
         seat_belt = $19, challan_if_any = $20, route_chart = $21, reflector_sticker = $22, seat_cover = $23,
         ac = $24, gps = $25, batches_whistle = $26, service = $27, washing = $28, todays_reading = $29,
         greasing = $30, brake_check = $31, wheel_alignment = $32, check_all_glasses = $33, lights_and_reflectors = $34,
         tyre = $35, air_check = $36 WHERE id = $37 RETURNING *`,
      [
        date,
        vehicle_name,
        driver_name,
        driving_license_renewal_date,
        vehicle_rc,
        insurance_renewal_date,
        pollution_renewal_date,
        mv_tax_date,
        counter_sign_renewal_date,
        passing_renewal_date,
        other_state_tax_renewal_date,
        permit_renewal_date,
        dvr_status,
        medical_box,
        camera1_status,
        camera2_status,
        camera3_status,
        fire_equipment,
        seat_belt,
        challan_if_any,
        route_chart,
        reflector_sticker,
        seat_cover,
        ac,
        gps,
        batches_whistle,
        service,
        washing,
        todays_reading,
        greasing,
        brake_check,
        wheel_alignment,
        check_all_glasses,
        lights_and_reflectors,
        tyre,
        air_check,
        id,
      ]
    );
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: 'Vehicle checklist not found' });
    }
  } catch (err) {
    console.error('Error updating vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to update vehicle checklist' });
  }
});

// DELETE a vehicle checklist
app.delete('/vehicle-checklist/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const { rowCount } = await pool.query('DELETE FROM vehicle_checklist WHERE id = $1', [id]);
    if (rowCount > 0) {
      res.json({ message: 'Vehicle checklist deleted successfully' });
    } else {
      res.status(404).json({ error: 'Vehicle checklist not found' });
    }
  } catch (err) {
    console.error('Error deleting vehicle checklist:', err);
    res.status(500).json({ error: 'Failed to delete vehicle checklist' });
  }
});

// Get all notes
app.get('/notes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM notes ORDER BY date');
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Create a new note
app.post('/notes', async (req, res) => {
  try {
    const { note_message } = req.body;
    const newNote = await pool.query(
      'INSERT INTO notes (note_message, date) VALUES ($1, CURRENT_DATE) RETURNING *',
      [note_message]
    );
    res.status(201).json(newNote.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Update a note
app.put('/notes/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { note_message } = req.body;
    const updatedNote = await pool.query(
      'UPDATE notes SET note_message = $1 WHERE id = $2 RETURNING *',
      [note_message, id]
    );
    res.json(updatedNote.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Delete a note
app.delete('/notes/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM notes WHERE id = $1', [id]);
    res.json({ message: "Note deleted successfully" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Get all walk-in records
app.get('/walk-in-records', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM walk_in_records ORDER BY date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new walk-in record
app.post('/walk-in-records', async (req, res) => {
    try {
        const { date, person_name, walk_in_type, purpose, whom_to_meet, mobile_no, email, scheduled, remarks } = req.body;
        const newRecord = await pool.query(
            'INSERT INTO walk_in_records (date, person_name, walk_in_type, purpose, whom_to_meet, mobile_no, email, scheduled, remarks) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
            [date, person_name, walk_in_type, purpose, whom_to_meet, mobile_no, email, scheduled, remarks]
        );
        res.json(newRecord.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update a walk-in record
app.put('/walk-in-records/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { date, person_name, walk_in_type, purpose, whom_to_meet, mobile_no, email, scheduled, remarks } = req.body;
        const updatedRecord = await pool.query(
            'UPDATE walk_in_records SET date = $1, person_name = $2, walk_in_type = $3, purpose = $4, whom_to_meet = $5, mobile_no = $6, email = $7, scheduled = $8, remarks = $9 WHERE id = $10 RETURNING *',
            [date, person_name, walk_in_type, purpose, whom_to_meet, mobile_no, email, scheduled, remarks, id]
        );
        res.json(updatedRecord.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete a walk-in record
app.delete('/walk-in-records/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM walk_in_records WHERE id = $1', [id]);
        res.json({ message: "Record deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Get all parent requests
app.get('/parent-requests', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM parent_requests ORDER BY request_date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new parent request
app.post('/parent-requests', async (req, res) => {
    try {
        const { student_name, request_name, request_date, parent_name, action_taken, staff_remark, staff_transferred, admin_remark } = req.body;
        const newRequest = await pool.query(
            'INSERT INTO parent_requests (student_name, request_name, request_date, parent_name, action_taken, staff_remark, staff_transferred, admin_remark) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
            [student_name, request_name, request_date, parent_name, action_taken, staff_remark, staff_transferred, admin_remark]
        );
        res.json(newRequest.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update a parent request
app.put('/parent-requests/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { student_name, request_name, request_date, parent_name, action_taken, staff_remark, staff_transferred, admin_remark } = req.body;
        const updatedRequest = await pool.query(
            'UPDATE parent_requests SET student_name = $1, request_name = $2, request_date = $3, parent_name = $4, action_taken = $5, staff_remark = $6, staff_transferred = $7, admin_remark = $8 WHERE id = $9 RETURNING *',
            [student_name, request_name, request_date, parent_name, action_taken, staff_remark, staff_transferred, admin_remark, id]
        );
        res.json(updatedRequest.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete a parent request
app.delete('/parent-requests/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM parent_requests WHERE id = $1', [id]);
        res.json({ message: "Request deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Get all daak received records
app.get('/daak-received', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM daak_received ORDER BY received_date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new daak received record
app.post('/daak-received', async (req, res) => {
    try {
        const { received_date, daak_number, daak_from, received_through, delivered_at, content, received_by, remark, assign_to, reassign_to, re_reassign_to } = req.body;

        let attachment = null;
        if (req.files && req.files.attachment) {
            const file = req.files.attachment;
            const uploadPath = path.join(__dirname, 'uploads', file.name);
            await file.mv(uploadPath);
            attachment = file.name;
        }

        const newDaak = await pool.query(
            'INSERT INTO daak_received (received_date, daak_number, daak_from, received_through, delivered_at, content, received_by, remark, assign_to, reassign_to, re_reassign_to, attachment) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *',
            [received_date, daak_number, daak_from, received_through, delivered_at, content, received_by, remark, assign_to, reassign_to, re_reassign_to, attachment]
        );
        res.json(newDaak.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update a daak received record
app.put('/daak-received/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { received_date, daak_number, daak_from, received_through, delivered_at, content, received_by, remark, assign_to, reassign_to, re_reassign_to } = req.body;

        let attachment = null;
        if (req.files && req.files.attachment) {
            const file = req.files.attachment;
            const uploadPath = path.join(__dirname, 'uploads', file.name);
            await file.mv(uploadPath);
            attachment = file.name;
        }

        const updatedDaak = await pool.query(
            'UPDATE daak_received SET received_date = $1, daak_number = $2, daak_from = $3, received_through = $4, delivered_at = $5, content = $6, received_by = $7, remark = $8, assign_to = $9, reassign_to = $10, re_reassign_to = $11, attachment = $12 WHERE id = $13 RETURNING *',
            [received_date, daak_number, daak_from, received_through, delivered_at, content, received_by, remark, assign_to, reassign_to, re_reassign_to, attachment, id]
        );
        res.json(updatedDaak.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete a daak received record
app.delete('/daak-received/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM daak_received WHERE id = $1', [id]);
        res.json({ message: "Daak deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Get all daak dispatched records
app.get('/daak-dispatched', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM daak_dispatched ORDER BY dispatch_date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new daak dispatched record
app.post('/daak-dispatched', async (req, res) => {
    try {
        const { dispatch_date, daak_number, dispatch_through, sent_to, content, tracking_number, charges_paid, remark } = req.body;

        let attachment = null;
        if (req.files && req.files.attachment) {
            const file = req.files.attachment;
            const uploadPath = path.join(__dirname, 'uploads', file.name);
            await file.mv(uploadPath);
            attachment = file.name;
        }

        const newDaak = await pool.query(
            'INSERT INTO daak_dispatched (dispatch_date, daak_number, dispatch_through, sent_to, content, tracking_number, charges_paid, remark, attachment) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
            [dispatch_date, daak_number, dispatch_through, sent_to, content, tracking_number, charges_paid, remark, attachment]
        );
        res.json(newDaak.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update a daak dispatched record
app.put('/daak-dispatched/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { dispatch_date, daak_number, dispatch_through, sent_to, content, tracking_number, charges_paid, remark } = req.body;

        let attachment = null;
        if (req.files && req.files.attachment) {
            const file = req.files.attachment;
            const uploadPath = path.join(__dirname, 'uploads', file.name);
            await file.mv(uploadPath);
            attachment = file.name;
        }

        const updatedDaak = await pool.query(
            'UPDATE daak_dispatched SET dispatch_date = $1, daak_number = $2, dispatch_through = $3, sent_to = $4, content = $5, tracking_number = $6, charges_paid = $7, remark = $8, attachment = $9 WHERE id = $10 RETURNING *',
            [dispatch_date, daak_number, dispatch_through, sent_to, content, tracking_number, charges_paid, remark, attachment, id]
        );
        res.json(updatedDaak.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete a daak dispatched record
app.delete('/daak-dispatched/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM daak_dispatched WHERE id = $1', [id]);
        res.json({ message: "Daak deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Get all incoming call records
app.get('/incoming-calls', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM incoming_calls ORDER BY call_date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new incoming call record
app.post('/incoming-calls', async (req, res) => {
    try {
        const { call_from_number, call_date, call_time, company_name, purpose_of_call, call_meant_for, message_received, call_transferred_to, remarks } = req.body;
        const newCall = await pool.query(
            'INSERT INTO incoming_calls (call_from_number, call_date, call_time, company_name, purpose_of_call, call_meant_for, message_received, call_transferred_to, remarks) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
            [call_from_number, call_date, call_time, company_name, purpose_of_call, call_meant_for, message_received, call_transferred_to, remarks]
        );
        res.json(newCall.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update an incoming call record
app.put('/incoming-calls/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { call_from_number, call_date, call_time, company_name, purpose_of_call, call_meant_for, message_received, call_transferred_to, remarks } = req.body;
        const updatedCall = await pool.query(
            'UPDATE incoming_calls SET call_from_number = $1, call_date = $2, call_time = $3, company_name = $4, purpose_of_call = $5, call_meant_for = $6, message_received = $7, call_transferred_to = $8, remarks = $9 WHERE id = $10 RETURNING *',
            [call_from_number, call_date, call_time, company_name, purpose_of_call, call_meant_for, message_received, call_transferred_to, remarks, id]
        );
        res.json(updatedCall.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete an incoming call record
app.delete('/incoming-calls/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM incoming_calls WHERE id = $1', [id]);
        res.json({ message: "Call deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Get all outgoing call records
app.get('/outgoing-calls', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM outgoing_calls ORDER BY call_date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new outgoing call record
app.post('/outgoing-calls', async (req, res) => {
    try {
        const { call_made_by, call_date, call_time, call_made_to, purpose_of_call, remarks } = req.body;
        const newCall = await pool.query(
            'INSERT INTO outgoing_calls (call_made_by, call_date, call_time, call_made_to, purpose_of_call, remarks) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
            [call_made_by, call_date, call_time, call_made_to, purpose_of_call, remarks]
        );
        res.json(newCall.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update an outgoing call record
app.put('/outgoing-calls/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { call_made_by, call_date, call_time, call_made_to, purpose_of_call, remarks } = req.body;
        const updatedCall = await pool.query(
            'UPDATE outgoing_calls SET call_made_by = $1, call_date = $2, call_time = $3, call_made_to = $4, purpose_of_call = $5, remarks = $6 WHERE id = $7 RETURNING *',
            [call_made_by, call_date, call_time, call_made_to, purpose_of_call, remarks, id]
        );
        res.json(updatedCall.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete an outgoing call record
app.delete('/outgoing-calls/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM outgoing_calls WHERE id = $1', [id]);
        res.json({ message: "Call deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Get all email records
app.get('/email-records', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM email_records ORDER BY received_date');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Create a new email record
app.post('/email-records', async (req, res) => {
    try {
        const { received_from, received_date, received_time, mail_for, subject, action_taken, remarks } = req.body;
        const newEmailRecord = await pool.query(
            'INSERT INTO email_records (received_from, received_date, received_time, mail_for, subject, action_taken, remarks) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
            [received_from, received_date, received_time, mail_for, subject, action_taken, remarks]
        );
        res.json(newEmailRecord.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Update an email record
app.put('/email-records/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { received_from, received_date, received_time, mail_for, subject, action_taken, remarks } = req.body;
        const updatedEmailRecord = await pool.query(
            'UPDATE email_records SET received_from = $1, received_date = $2, received_time = $3, mail_for = $4, subject = $5, action_taken = $6, remarks = $7 WHERE id = $8 RETURNING *',
            [received_from, received_date, received_time, mail_for, subject, action_taken, remarks, id]
        );
        res.json(updatedEmailRecord.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Delete an email record
app.delete('/email-records/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM email_records WHERE id = $1', [id]);
        res.json({ message: "Email record deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

const inchargeUpload = multer({
    dest: 'uploads/',
    limits: { fileSize: 4 * 1024 * 1024 }, // 4 MB
    fileFilter: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        if (ext !== '.png' && ext !== '.jpg' && ext !== '.jpeg' && ext !== '.pdf') {
            return cb(new Error('Only images and PDFs are allowed'));
        }
        cb(null, true);
    },
});

// Create a new incharge record
app.post('/incharge-list', inchargeUpload.single('attachment'), async (req, res) => {
    const {
        date, teacher, student, red_mark, dress_defaulter, short_leave, more_than_7_days, new_entry,
        late_arrivals, visitors, uniform, discipline, mid_day_meal, reception, examination,
        telephonic_contact, circular, class: className, time_table, problem_in_ground, fees,
        requirement, advance, maid, sweepers, peon, transport, cbse, lab, departure,
        any_other_thing, note_book_checking, note_book_status, information, minutes_of_meeting,
        observation, pending_from_office, remarks, posted_by, status
    } = req.body;

    const attachment = req.file ? req.file.filename : null;

    try {
        const result = await pool.query(
            `INSERT INTO incharge_list (
                date, teacher, student, red_mark, dress_defaulter, short_leave, more_than_7_days, new_entry,
                late_arrivals, visitors, uniform, discipline, mid_day_meal, reception, examination,
                telephonic_contact, circular, class, time_table, problem_in_ground, fees,
                requirement, advance, maid, sweepers, peon, transport, cbse, lab, departure,
                any_other_thing, note_book_checking, note_book_status, information, minutes_of_meeting,
                observation, pending_from_office, remarks, attachment, posted_by, status
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41)
            RETURNING *`,
            [
                date, teacher, student, red_mark, dress_defaulter, short_leave, more_than_7_days, new_entry,
                late_arrivals, visitors, uniform, discipline, mid_day_meal, reception, examination,
                telephonic_contact, circular, className, time_table, problem_in_ground, fees,
                requirement, advance, maid, sweepers, peon, transport, cbse, lab, departure,
                any_other_thing, note_book_checking, note_book_status, information, minutes_of_meeting,
                observation, pending_from_office, remarks, attachment, posted_by, status
            ]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Get all incharge records
app.get('/incharge-list', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM incharge_list ORDER BY date DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Update an incharge record
app.put('/incharge-list/:id', inchargeUpload.single('attachment'), async (req, res) => {
    const { id } = req.params;
    const {
        date, teacher, student, red_mark, dress_defaulter, short_leave, more_than_7_days, new_entry,
        late_arrivals, visitors, uniform, discipline, mid_day_meal, reception, examination,
        telephonic_contact, circular, class: className, time_table, problem_in_ground, fees,
        requirement, advance, maid, sweepers, peon, transport, cbse, lab, departure,
        any_other_thing, note_book_checking, note_book_status, information, minutes_of_meeting,
        observation, pending_from_office, remarks, posted_by, status
    } = req.body;

    const attachment = req.file ? req.file.filename : null;

    try {
        const result = await pool.query(
            `UPDATE incharge_list SET
                date = $1, teacher = $2, student = $3, red_mark = $4, dress_defaulter = $5,
                short_leave = $6, more_than_7_days = $7, new_entry = $8, late_arrivals = $9,
                visitors = $10, uniform = $11, discipline = $12, mid_day_meal = $13, reception = $14,
                examination = $15, telephonic_contact = $16, circular = $17, class = $18,
                time_table = $19, problem_in_ground = $20, fees = $21, requirement = $22,
                advance = $23, maid = $24, sweepers = $25, peon = $26, transport = $27,
                cbse = $28, lab = $29, departure = $30, any_other_thing = $31, note_book_checking = $32,
                note_book_status = $33, information = $34, minutes_of_meeting = $35, observation = $36,
                pending_from_office = $37, remarks = $38, attachment = COALESCE($39, attachment),
                posted_by = $40, status = $41
            WHERE id = $42 RETURNING *`,
            [
                date, teacher, student, red_mark, dress_defaulter, short_leave, more_than_7_days, new_entry,
                late_arrivals, visitors, uniform, discipline, mid_day_meal, reception, examination,
                telephonic_contact, circular, className, time_table, problem_in_ground, fees,
                requirement, advance, maid, sweepers, peon, transport, cbse, lab, departure,
                any_other_thing, note_book_checking, note_book_status, information, minutes_of_meeting,
                observation, pending_from_office, remarks, attachment, posted_by, status, id
            ]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Delete an incharge record
app.delete('/incharge-list/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM incharge_list WHERE id = $1', [id]);
        res.json({ message: 'Incharge record deleted successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Change status of an incharge record
app.put('/incharge-list/status/:id', async (req, res) => {
    const { id } = req.params;
    const { status, remarks } = req.body;
    try {
        const result = await pool.query(
            'UPDATE incharge_list SET status = $1, remarks = $2 WHERE id = $3 RETURNING *',
            [status, remarks, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Serve attachments
app.get('/uploads/:filename', (req, res) => {
    const { filename } = req.params;
    const file = path.resolve(__dirname, 'uploads', filename);
    res.sendFile(file);
});

// Leave Type Routes
app.get('/leave-types', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM leave_types');
    const leaveTypes = result.rows;

    for (let leaveType of leaveTypes) {
      const staffResult = await pool.query(
        'SELECT * FROM staff_list WHERE id = ANY($1::int[])',
        [leaveType.staff_ids || []]
      );
      leaveType.staff_list = staffResult.rows;
    }

    res.json(leaveTypes);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

app.post('/leave-types', async (req, res) => {
  try {
    const {
      name,
      positive_value,
      negative_value,
      starting_delay_time,
      ending_delay_time,
      colour_code,
      text_colour,
      name_on_app,
      order_no,
      for_staff,
      for_student,
      show_in_leave,
      show_in_attendance,
      show_in_leave_allowance,
      staff_ids
    } = req.body;

    const result = await pool.query(
      'INSERT INTO leave_types (name, positive_value, negative_value, starting_delay_time, ending_delay_time, colour_code, text_colour, name_on_app, order_no, for_staff, for_student, show_in_leave, show_in_attendance, show_in_leave_allowance, staff_ids) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) RETURNING *',
      [
        name,
        positive_value,
        negative_value,
        starting_delay_time,
        ending_delay_time,
        colour_code,
        text_colour,
        name_on_app,
        order_no,
        for_staff,
        for_student,
        show_in_leave,
        show_in_attendance,
        show_in_leave_allowance,
        staff_ids
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

app.put('/leave-types/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      positive_value,
      negative_value,
      starting_delay_time,
      ending_delay_time,
      colour_code,
      text_colour,
      name_on_app,
      order_no,
      for_staff,
      for_student,
      show_in_leave,
      show_in_attendance,
      show_in_leave_allowance,
      staff_ids
    } = req.body;

    const result = await pool.query(
      'UPDATE leave_types SET name = $1, positive_value = $2, negative_value = $3, starting_delay_time = $4, ending_delay_time = $5, colour_code = $6, text_colour = $7, name_on_app = $8, order_no = $9, for_staff = $10, for_student = $11, show_in_leave = $12, show_in_attendance = $13, show_in_leave_allowance = $14, staff_ids = $15 WHERE id = $16 RETURNING *',
      [
        name,
        positive_value,
        negative_value,
        starting_delay_time,
        ending_delay_time,
        colour_code,
        text_colour,
        name_on_app,
        order_no,
        for_staff,
        for_student,
        show_in_leave,
        show_in_attendance,
        show_in_leave_allowance,
        staff_ids,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ msg: 'Leave type not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

app.delete('/leave-types/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query('DELETE FROM leave_types WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ msg: 'Leave type not found' });
    }

    res.json({ msg: 'Leave type deleted' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Leave Approve Master Routes
app.get('/leave-approve-master', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM leave_approve_master');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching leave approve master list', error);
    res.status(500).json({ error: 'Failed to fetch leave approve master list' });
  }
});

app.post('/leave-approve-master', async (req, res) => {
  const { level, type, staff } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO leave_approve_master (level, type, staff) VALUES ($1, $2, $3) RETURNING *',
      [level, type, staff]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating leave approve master', error);
    res.status(500).json({ error: 'Failed to create leave approve master' });
  }
});

app.put('/leave-approve-master/:id', async (req, res) => {
  const { id } = req.params;
  const { level, type, staff } = req.body;
  try {
    const result = await pool.query(
      'UPDATE leave_approve_master SET level = $1, type = $2, staff = $3 WHERE id = $4 RETURNING *',
      [level, type, staff, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error editing leave approve master', error);
    res.status(500).json({ error: 'Failed to edit leave approve master' });
  }
});

app.delete('/leave-approve-master/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM leave_approve_master WHERE id = $1', [id]);
    res.status(200).json({ message: 'Leave approve master deleted' });
  } catch (error) {
    console.error('Error deleting leave approve master', error);
    res.status(500).json({ error: 'Failed to delete leave approve master' });
  }
});

// Leave Rules Master Routes
app.get('/leave-rules-master', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM leave_rules_master');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching leave rules master list', error);
    res.status(500).json({ error: 'Failed to fetch leave rules master list' });
  }
});

app.post('/leave-rules-master', async (req, res) => {
  const { leave_type, leave_counter, marks_as, marks_leave_counter, execute_order } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO leave_rules_master (leave_type, leave_counter, marks_as, marks_leave_counter, execute_order) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [leave_type, leave_counter, marks_as, marks_leave_counter, execute_order]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating leave rules master', error);
    res.status(500).json({ error: 'Failed to create leave rules master' });
  }
});

app.put('/leave-rules-master/:id', async (req, res) => {
  const { id } = req.params;
  const { leave_type, leave_counter, marks_as, marks_leave_counter, execute_order } = req.body;
  try {
    const result = await pool.query(
      'UPDATE leave_rules_master SET leave_type = $1, leave_counter = $2, marks_as = $3, marks_leave_counter = $4, execute_order = $5 WHERE id = $6 RETURNING *',
      [leave_type, leave_counter, marks_as, marks_leave_counter, execute_order, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error editing leave rules master', error);
    res.status(500).json({ error: 'Failed to edit leave rules master' });
  }
});

app.delete('/leave-rules-master/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM leave_rules_master WHERE id = $1', [id]);
    res.status(200).json({ message: 'Leave rules master deleted' });
  } catch (error) {
    console.error('Error deleting leave rules master', error);
    res.status(500).json({ error: 'Failed to delete leave rules master' });
  }
});

// Leave List Routes
app.get('/leave-list', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        l.id,
        l.user_type,
        l.name,
        l.apply_on,
        lt.name as leave_type,
        l.start_date,
        l.end_date,
        l.days,
        l.status
      FROM
        leaves l
      JOIN
        leave_types lt ON l.leave_type_id = lt.id
      ORDER BY
        l.apply_on DESC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching leave list', error);
    res.status(500).json({ error: 'Failed to fetch leave list' });
  }
});

app.get('/approve-staff-leave', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        l.id AS serial_no,
        s.name AS applied_by,
        s.department,
        l.apply_on AS applied_on,
        l.start_date || ' - ' || l.end_date AS date,
        lt.name AS leave_type,
        l.remarks
      FROM
        leaves l
      JOIN
        staff_list s ON l.user_id = s.id
      JOIN
        leave_types lt ON l.leave_type_id = lt.id
      WHERE
        l.user_type = 'staff'
      ORDER BY
        l.id ASC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching staff leave list', error);
    res.status(500).json({ error: 'Failed to fetch staff leave list' });
  }
});

app.get('/approve-student-leave', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        l.id AS serial_no,
        st.student_name AS applied_by,
        st.class_section AS class,
        l.apply_on AS applied_on,
        l.start_date || ' - ' || l.end_date AS date,
        lt.name AS leave_type,
        l.remarks
      FROM
        leaves l
      JOIN
        student_list st ON l.user_id = st.serial_no
      JOIN
        leave_types lt ON l.leave_type_id = lt.id
      WHERE
        l.user_type = 'student'
      ORDER BY
        l.id ASC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching student leave list', error);
    res.status(500).json({ error: 'Failed to fetch student leave list' });
  }
});

// Permission for Other Staff (Leave) Routes
app.get('/permission-for-other-staff', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        p.id,
        s.name AS staff_name,
        p.leave_reason
      FROM
        permissions p
      JOIN
        staff_list s ON p.staff_id = s.id
      ORDER BY
        p.id ASC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching permission list', error);
    res.status(500).json({ error: 'Failed to fetch permission list' });
  }
});

app.post('/permission-for-other-staff', async (req, res) => {
  const { staff_name, leave_reason } = req.body;
  try {
    const staffResult = await pool.query('SELECT id FROM staff_list WHERE name = $1', [staff_name]);
    if (staffResult.rows.length === 0) {
      return res.status(400).json({ error: 'Staff not found' });
    }
    const staffId = staffResult.rows[0].id;

    const result = await pool.query(
      'INSERT INTO permissions (staff_id, leave_reason) VALUES ($1, $2) RETURNING *',
      [staffId, leave_reason]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating permission', error);
    res.status(500).json({ error: 'Failed to create permission' });
  }
});

app.put('/permission-for-other-staff/:id', async (req, res) => {
  const { id } = req.params;
  const { staff_name, leave_reason } = req.body;
  try {
    const staffResult = await pool.query('SELECT id FROM staff_list WHERE name = $1', [staff_name]);
    if (staffResult.rows.length === 0) {
      return res.status(400).json({ error: 'Staff not found' });
    }
    const staffId = staffResult.rows[0].id;

    const result = await pool.query(
      'UPDATE permissions SET staff_id = $1, leave_reason = $2 WHERE id = $3 RETURNING *',
      [staffId, leave_reason, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating permission', error);
    res.status(500).json({ error: 'Failed to update permission' });
  }
});

app.delete('/permission-for-other-staff/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM permissions WHERE id = $1', [id]);
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting permission', error);
    res.status(500).json({ error: 'Failed to delete permission' });
  }
});

// Fetch appointments and messages
// Fetch all appointments and messaging
app.get('/appointments-messaging', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM appointments_messaging ORDER BY id ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching appointments and messaging', error);
    res.status(500).json({ error: 'Failed to fetch appointments and messaging' });
  }
});

// Apply new appointment or message
app.post('/appointments-messaging', async (req, res) => {
  const { type, appointment_for, reason, requested_by, class: className, date_time, requested_on, assign_to, status, message } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO appointments_messaging
        (type, appointment_for, reason, requested_by, class, date_time, requested_on, assign_to, status, message)
        VALUES
        ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
      `,
      [type, appointment_for, reason, requested_by, className, date_time, requested_on, assign_to, status, message]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error applying new appointment or message', error);
    res.status(500).json({ error: 'Failed to apply new appointment or message' });
  }
});

app.get('/dashboard-data', async (req, res) => {
  try {
    const allClasses = ['6A', '6B', '6C', '7A', '7B', '7C', '8A', '8B', '8C', '9A', '9B', '9C', '10A', '10B', '10C', '11A', '11B', '11C', '12A', '12B', '12C'];

    const classCounts = await pool.query('SELECT class_section, COUNT(*) FROM student_list GROUP BY class_section');
    const classDistribution = allClasses.map(classSection => {
      const foundClass = classCounts.rows.find(row => row.class_section === classSection);
      return { class: classSection, count: foundClass ? parseInt(foundClass.count, 10) : 0 };
    });

    const totalStudents = classCounts.rows.reduce((sum, row) => sum + parseInt(row.count, 10), 0);
    const totalStaff = await pool.query('SELECT COUNT(*) FROM staff_list');
    const totalClasses = allClasses.length;
    const staffDistribution = await pool.query('SELECT department, COUNT(*) AS count FROM staff_list GROUP BY department');
    const recentExpenditures = await pool.query('SELECT category, description, amount, date FROM expenditures ORDER BY date DESC LIMIT 10');
    const recentFeeRecords = await pool.query('SELECT student_name, fees_amount, payment_mode, date FROM feesrecord ORDER BY date DESC LIMIT 10');

    const data = {
      totalStudents: totalStudents,
      totalStaff: totalStaff.rows[0].count,
      totalClasses: totalClasses,
      classDistribution: classDistribution,
      staffDistribution: staffDistribution.rows,
      recentExpenditures: recentExpenditures.rows,
      recentFeeRecords: recentFeeRecords.rows,
    };

    res.status(200).json(data);
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    res.status(500).json({ message: 'Failed to fetch dashboard data. Please try again.' });
  }
});

// Get all terms
app.get('/terms', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM terms ORDER BY order_no ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching terms', err);
    res.status(500).json({ message: 'Error fetching terms' });
  }
});

// Add new term
app.post('/terms', async (req, res) => {
  const { term_name, start_date, end_date, term_code, order_no } = req.body;
  try {
    await pool.query(
      'INSERT INTO terms (term_name, start_date, end_date, term_code, order_no) VALUES ($1, $2, $3, $4, $5)',
      [term_name, start_date, end_date, term_code, order_no]
    );
    res.status(201).json({ message: 'Term added successfully' });
  } catch (err) {
    console.error('Error adding term', err);
    res.status(500).json({ message: 'Error adding term' });
  }
});

// Edit term
app.put('/terms/:id', async (req, res) => {
  const { id } = req.params;
  const { term_name, start_date, end_date, term_code, order_no } = req.body;
  try {
    await pool.query(
      'UPDATE terms SET term_name = $1, start_date = $2, end_date = $3, term_code = $4, order_no = $5 WHERE id = $6',
      [term_name, start_date, end_date, term_code, order_no, id]
    );
    res.status(200).json({ message: 'Term updated successfully' });
  } catch (err) {
    console.error('Error updating term', err);
    res.status(500).json({ message: 'Error updating term' });
  }
});

// Delete term
app.delete('/terms/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM terms WHERE id = $1', [id]);
    res.status(200).json({ message: 'Term deleted successfully' });
  } catch (err) {
    console.error('Error deleting term', err);
    res.status(500).json({ message: 'Error deleting term' });
  }
});

// Get all assessments
app.get('/assessments', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT assessments.id, terms.term_name AS term, assessments.name, assessments.code
      FROM assessments
      JOIN terms ON assessments.term_id = terms.id
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching assessments:', err);
    res.status(500).json({ message: 'Failed to fetch assessments. Please try again.' });
  }
});

// Add a new assessment
app.post('/assessments', async (req, res) => {
  const { term_id, name, code } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO assessments (term_id, name, code) VALUES ($1, $2, $3) RETURNING *`,
      [term_id, name, code]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding assessment:', err);
    res.status(500).json({ message: 'Failed to add assessment. Please try again.' });
  }
});

// Edit an assessment
app.put('/assessments/:id', async (req, res) => {
  const { id } = req.params;
  const { term_id, name, code } = req.body;
  try {
    const result = await pool.query(
      `UPDATE assessments SET term_id = $1, name = $2, code = $3 WHERE id = $4 RETURNING *`,
      [term_id, name, code, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing assessment:', err);
    res.status(500).json({ message: 'Failed to edit assessment. Please try again.' });
  }
});

// Delete an assessment
app.delete('/assessments/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query(`DELETE FROM assessments WHERE id = $1`, [id]);
    res.status(200).json({ message: 'Assessment deleted successfully' });
  } catch (err) {
    console.error('Error deleting assessment:', err);
    res.status(500).json({ message: 'Failed to delete assessment. Please try again.' });
  }
});

// Get all grade categories
app.get('/grade-categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM grade_categories ORDER BY id');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching grade categories:', err);
    res.status(500).json({ message: 'Failed to fetch grade categories. Please try again.' });
  }
});

// Add a new grade category
app.post('/grade-categories', async (req, res) => {
  const { name, max_value, order_no } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO grade_categories (name, max_value, order_no) VALUES ($1, $2, $3) RETURNING *',
      [name, max_value, order_no]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding grade category:', err);
    res.status(500).json({ message: 'Failed to add grade category. Please try again.' });
  }
});

// Edit a grade category
app.put('/grade-categories/:id', async (req, res) => {
  const { id } = req.params;
  const { name, max_value, order_no } = req.body;
  try {
    const result = await pool.query(
      'UPDATE grade_categories SET name = $1, max_value = $2, order_no = $3 WHERE id = $4 RETURNING *',
      [name, max_value, order_no, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing grade category:', err);
    res.status(500).json({ message: 'Failed to edit grade category. Please try again.' });
  }
});

// Delete a grade category
app.delete('/grade-categories/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM grade_categories WHERE id = $1', [id]);
    res.status(200).json({ message: 'Grade category deleted successfully' });
  } catch (err) {
    console.error('Error deleting grade category:', err);
    res.status(500).json({ message: 'Failed to delete grade category. Please try again.' });
  }
});

// Get all grades with category names
app.get('/grades', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT g.id, g.name, g.from_range, g.to_range, g.point, gc.name AS category_name, g.order_no, g.color_code, g.back_color_code, g.display_message
      FROM grades g
      JOIN grade_categories gc ON g.category_id = gc.id
      ORDER BY g.id
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching grades:', err);
    res.status(500).json({ message: 'Failed to fetch grades. Please try again.' });
  }
});

// Get all grade categories for dropdown
app.get('/grade-categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name FROM grade_categories ORDER BY name');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching grade categories:', err);
    res.status(500).json({ message: 'Failed to fetch grade categories. Please try again.' });
  }
});

// Add a new grade
app.post('/grades', async (req, res) => {
  const { name, from_range, to_range, point, category_id, order_no, color_code, back_color_code, display_message } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO grades (name, from_range, to_range, point, category_id, order_no, color_code, back_color_code, display_message) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
      [name, from_range, to_range, point, category_id, order_no, color_code, back_color_code, display_message]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding grade:', err);
    res.status(500).json({ message: 'Failed to add grade. Please try again.' });
  }
});

// Edit a grade
app.put('/grades/:id', async (req, res) => {
  const { id } = req.params;
  const { name, from_range, to_range, point, category_id, order_no, color_code, back_color_code, display_message } = req.body;
  try {
    const result = await pool.query(
      'UPDATE grades SET name = $1, from_range = $2, to_range = $3, point = $4, category_id = $5, order_no = $6, color_code = $7, back_color_code = $8, display_message = $9 WHERE id = $10 RETURNING *',
      [name, from_range, to_range, point, category_id, order_no, color_code, back_color_code, display_message, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing grade:', err);
    res.status(500).json({ message: 'Failed to edit grade. Please try again.' });
  }
});

// Delete a grade
app.delete('/grades/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM grades WHERE id = $1', [id]);
    res.status(200).json({ message: 'Grade deleted successfully' });
  } catch (err) {
    console.error('Error deleting grade:', err);
    res.status(500).json({ message: 'Failed to delete grade. Please try again.' });
  }
});

// Get all exams with related details
app.get('/exams', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT e.id, a.name AS assessment, gc.name AS grade_category, e.display_in, s.subject_name, e.class_section, e.activity, e.subject_type, e.grade, e.passing_marks, e.maximum_marks, e.hide_from_report_card, e.display_character
      FROM exams e
      JOIN assessments a ON e.assessment_id = a.id
      JOIN grade_categories gc ON e.grade_category_id = gc.id
      JOIN subject_master s ON e.subject_id = s.id
      ORDER BY e.id
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching exams:', err);
    res.status(500).json({ message: 'Failed to fetch exams. Please try again.' });
  }
});

// Add a new exam
app.post('/exams', async (req, res) => {
  const { assessment_id, grade_category_id, display_in, subject_id, class_section, activity, subject_type, grade, passing_marks, maximum_marks, hide_from_report_card, display_character } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO exams (assessment_id, grade_category_id, display_in, subject_id, class_section, activity, subject_type, grade, passing_marks, maximum_marks, hide_from_report_card, display_character) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *',
      [assessment_id, grade_category_id, display_in, subject_id, class_section, activity, subject_type, grade, passing_marks, maximum_marks, hide_from_report_card, display_character]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding exam:', err);
    res.status(500).json({ message: 'Failed to add exam. Please try again.' });
  }
});

// Edit an exam
app.put('/exams/:id', async (req, res) => {
  const { id } = req.params;
  const { assessment_id, grade_category_id, display_in, subject_id, class_section, activity, subject_type, grade, passing_marks, maximum_marks, hide_from_report_card, display_character } = req.body;
  try {
    const result = await pool.query(
      'UPDATE exams SET assessment_id = $1, grade_category_id = $2, display_in = $3, subject_id = $4, class_section = $5, activity = $6, subject_type = $7, grade = $8, passing_marks = $9, maximum_marks = $10, hide_from_report_card = $11, display_character = $12 WHERE id = $13 RETURNING *',
      [assessment_id, grade_category_id, display_in, subject_id, class_section, activity, subject_type, grade, passing_marks, maximum_marks, hide_from_report_card, display_character, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing exam:', err);
    res.status(500).json({ message: 'Failed to edit exam. Please try again.' });
  }
});

// Delete an exam
app.delete('/exams/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM exams WHERE id = $1', [id]);
    res.status(200).json({ message: 'Exam deleted successfully' });
  } catch (err) {
    console.error('Error deleting exam:', err);
    res.status(500).json({ message: 'Failed to delete exam. Please try again.' });
  }
});

// Get all report card designs
app.get('/report-card-designs', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM report_card_designs ORDER BY id');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching report card designs:', error);
    res.status(500).json({ message: 'Failed to fetch report card designs. Please try again.' });
  }
});

// Add a new report card design
app.post('/report-card-designs', async (req, res) => {
  const { name, allow_student_to_see, page_no, reports_per_page, assessment_id, class_sections } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO report_card_designs (name, allow_student_to_see, page_no, reports_per_page, assessment_id, class_sections) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [name, allow_student_to_see, page_no, reports_per_page, assessment_id, JSON.stringify(class_sections)]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error adding report card design:', error);
    res.status(500).json({ message: 'Failed to add report card design. Please try again.' });
  }
});

// Edit a report card design
app.put('/report-card-designs/:id', async (req, res) => {
  const { id } = req.params;
  const { name, allow_student_to_see, page_no, reports_per_page, assessment_id, class_sections } = req.body;
  try {
    const result = await pool.query(
      'UPDATE report_card_designs SET name = $1, allow_student_to_see = $2, page_no = $3, reports_per_page = $4, assessment_id = $5, class_sections = $6 WHERE id = $7 RETURNING *',
      [name, allow_student_to_see, page_no, reports_per_page, assessment_id, JSON.stringify(class_sections), id]
    );
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error('Error editing report card design:', error);
    res.status(500).json({ message: 'Failed to edit report card design. Please try again.' });
  }
});

// Delete a report card design
app.delete('/report-card-designs/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM report_card_designs WHERE id = $1', [id]);
    res.status(200).json({ message: 'Report card design deleted successfully.' });
  } catch (error) {
    console.error('Error deleting report card design:', error);
    res.status(500).json({ message: 'Failed to delete report card design. Please try again.' });
  }
});

// Fetch uploaded student report cards
app.get('/uploadedReportCards', async (req, res) => {
  const offset = parseInt(req.query.offset, 10) || 0;
  const limit = parseInt(req.query.limit, 10) || 100;

  try {
    const result = await pool.query(
      'SELECT * FROM uploaded_student_report_cards ORDER BY id ASC LIMIT $1 OFFSET $2',
      [limit, offset]
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching uploaded report cards:', err);
    res.status(500).json({ message: 'Failed to fetch uploaded report cards. Please try again.' });
  }
});

// Add a new uploaded report card
app.post('/addReportCard', async (req, res) => {
  const { enrollment_no, roll_no, name, class_section, report_card, student_id } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO uploaded_student_report_cards (enrollment_no, roll_no, name, class_section, report_card, student_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [enrollment_no, roll_no, name, class_section, report_card, student_id]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding report card:', err);
    res.status(500).json({ message: 'Failed to add report card. Please try again.' });
  }
});

// Update an uploaded report card
app.put('/updateReportCard/:id', async (req, res) => {
  const { id } = req.params;
  const { enrollment_no, roll_no, name, class_section, report_card, student_id } = req.body;

  try {
    const result = await pool.query(
      `UPDATE uploaded_student_report_cards
       SET enrollment_no = $1, roll_no = $2, name = $3, class_section = $4, report_card = $5, student_id = $6
       WHERE id = $7
       RETURNING *`,
      [enrollment_no, roll_no, name, class_section, report_card, student_id, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating report card:', err);
    res.status(500).json({ message: 'Failed to update report card. Please try again.' });
  }
});

// Delete an uploaded report card
app.delete('/deleteReportCard/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query('DELETE FROM uploaded_student_report_cards WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting report card:', err);
    res.status(500).json({ message: 'Failed to delete report card. Please try again.' });
  }
});

app.get('/class-subject-orders', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT cso.id, cm.class_name, sm.subject_name, cso.order_no
       FROM class_subject_order cso
       JOIN class_master cm ON cso.class_id = cm.id
       JOIN subject_master sm ON cso.subject_id = sm.id
       ORDER BY cso.order_no ASC`
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching class-subject orders:', err);
    res.status(500).json({ message: 'Failed to fetch class-subject orders. Please try again.' });
  }
});

app.post('/class-subject-orders', async (req, res) => {
  const { class_id, subject_id, order_no } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO class_subject_order (class_id, subject_id, order_no)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [class_id, subject_id, order_no]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding class-subject order:', err);
    res.status(500).json({ message: 'Failed to add class-subject order. Please try again.' });
  }
});

app.put('/class-subject-orders/:id', async (req, res) => {
  const { id } = req.params;
  const { class_id, subject_id, order_no } = req.body;
  try {
    const result = await pool.query(
      `UPDATE class_subject_order
       SET class_id = $1, subject_id = $2, order_no = $3
       WHERE id = $4
       RETURNING *`,
      [class_id, subject_id, order_no, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating class-subject order:', err);
    res.status(500).json({ message: 'Failed to update class-subject order. Please try again.' });
  }
});

app.delete('/class-subject-orders/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM class_subject_order WHERE id = $1', [id]);
    res.status(200).json({ message: 'Class-subject order deleted successfully.' });
  } catch (err) {
    console.error('Error deleting class-subject order:', err);
    res.status(500).json({ message: 'Failed to delete class-subject order. Please try again.' });
  }
});

app.get('/class-subjects', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT cs.id, cm.class_name, sm.subject_name, cs.order_no
      FROM class_subject_order cs
      JOIN class_master cm ON cs.class_id = cm.id
      JOIN subject_master sm ON cs.subject_id = sm.id
      ORDER BY cs.class_id, cs.order_no
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching class subjects:', err);
    res.status(500).json({ message: 'Failed to fetch class subjects. Please try again.' });
  }
});

app.post('/class-subjects', async (req, res) => {
  const { class_id, subject_id, order_no } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO class_subject_order (class_id, subject_id, order_no)
       VALUES ($1, $2, $3) RETURNING *`,
      [class_id, subject_id, order_no]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding class subject:', err);
    res.status(500).json({ message: 'Failed to add class subject. Please try again.' });
  }
});

app.put('/class-subjects/:id', async (req, res) => {
  const { id } = req.params;
  const { class_id, subject_id, order_no } = req.body;
  try {
    const result = await pool.query(
      `UPDATE class_subject_order SET class_id = $1, subject_id = $2, order_no = $3
       WHERE id = $4 RETURNING *`,
      [class_id, subject_id, order_no, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating class subject:', err);
    res.status(500).json({ message: 'Failed to update class subject. Please try again.' });
  }
});

app.delete('/class-subjects/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM class_subject_order WHERE id = $1', [id]);
    res.status(200).json({ message: 'Class subject deleted successfully.' });
  } catch (err) {
    console.error('Error deleting class subject:', err);
    res.status(500).json({ message: 'Failed to delete class subject. Please try again.' });
  }
});

app.get('/daily-marks-entries', async (req, res) => {
  const offset = parseInt(req.query.offset, 10) || 0;
  const limit = parseInt(req.query.limit, 10) || 100;

  try {
    const result = await pool.query(
      `SELECT d.id, d.date, d.class_section, s.subject_name, d.max_marks
       FROM daily_marks_entry d
       JOIN subject_master s ON d.subject_id = s.id
       ORDER BY d.date DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching daily marks entries:', err);
    res.status(500).json({ message: 'Failed to fetch daily marks entries. Please try again.' });
  }
});

app.post('/daily-marks-entries', async (req, res) => {
  const { date, class_section, subject_id, max_marks } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO daily_marks_entry (date, class_section, subject_id, max_marks)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [date, class_section, subject_id, max_marks]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding daily marks entry:', err);
    res.status(500).json({ message: 'Failed to add daily marks entry. Please try again.' });
  }
});

app.put('/daily-marks-entries/:id', async (req, res) => {
  const { id } = req.params;
  const { date, class_section, subject_id, max_marks } = req.body;

  try {
    const result = await pool.query(
      `UPDATE daily_marks_entry
       SET date = $1, class_section = $2, subject_id = $3, max_marks = $4
       WHERE id = $5
       RETURNING *`,
      [date, class_section, subject_id, max_marks, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing daily marks entry:', err);
    res.status(500).json({ message: 'Failed to edit daily marks entry. Please try again.' });
  }
});

app.delete('/daily-marks-entries/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query('DELETE FROM daily_marks_entry WHERE id = $1', [id]);
    res.status(200).json({ message: 'Daily marks entry deleted successfully.' });
  } catch (err) {
    console.error('Error deleting daily marks entry:', err);
    res.status(500).json({ message: 'Failed to delete daily marks entry. Please try again.' });
  }
});

app.get('/grades', async (req, res) => {
  const studentId = req.query.studentId;
  const assessmentId = req.query.assessmentId;

  try {
    const result = await pool.query(
      `SELECT * FROM nurseryGrade WHERE student_id = $1 AND assessment_id = $2`,
      [studentId, assessmentId]
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching grades:', err);
    res.status(500).json({ message: 'Failed to fetch grades. Please try again.' });
  }
});

app.post('/grades', async (req, res) => {
  const { student_id, assessment_id, subject_id, grade, remarks } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO nurseryGrade (student_id, assessment_id, subject_id, grade, remarks)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [student_id, assessment_id, subject_id, grade, remarks]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding grade:', err);
    res.status(500).json({ message: 'Failed to add grade. Please try again.' });
  }
});

app.put('/grades/:id', async (req, res) => {
  const { id } = req.params;
  const { grade, remarks } = req.body;

  try {
    const result = await pool.query(
      `UPDATE grades SET nurseryGrade = $1, remarks = $2 WHERE id = $3 RETURNING *`,
      [grade, remarks, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating grade:', err);
    res.status(500).json({ message: 'Failed to update grade. Please try again.' });
  }
});

app.delete('/grades/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query('DELETE FROM nurseryGrade WHERE id = $1', [id]);
    res.status(200).json({ message: 'Grade deleted successfully.' });
  } catch (err) {
    console.error('Error deleting grade:', err);
    res.status(500).json({ message: 'Failed to delete grade. Please try again.' });
  }
});

app.get('/marks-entries', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        me.id,
        t.term_name,
        me.class_section,
        a.name AS assessment_name,
        s.subject_name,
        me.student_list
      FROM marks_entries me
      JOIN terms t ON me.term_id = t.id
      JOIN assessments a ON me.assessment_id = a.id
      JOIN subject_master s ON me.subject_id = s.id
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching marks entries:', err);
    res.status(500).send(err.message);
  }
});

app.get('/class-sections', async (req, res) => {
  try {
    const result = await pool.query('SELECT DISTINCT class_section FROM student_list');
    res.json(result.rows.map(row => row.class_section));
  } catch (err) {
    console.error('Error fetching class sections:', err);
    res.status(500).send(err.message);
  }
});

app.post('/marks-entries', async (req, res) => {
  const { term_id, class_section, assessment_id, subject_id, student_list } = req.body;
  try {
    await pool.query(
      'INSERT INTO marks_entries (term_id, class_section, assessment_id, subject_id, student_list) VALUES ($1, $2, $3, $4, $5)',
      [term_id, class_section, assessment_id, subject_id, student_list]
    );
    res.status(201).send('Marks entry added');
  } catch (err) {
    console.error('Error adding marks entry:', err);
    res.status(500).send(err.message);
  }
});

app.put('/marks-entries/:id', async (req, res) => {
  const { id } = req.params;
  const { term_id, class_section, assessment_id, subject_id, student_list } = req.body;
  try {
    await pool.query(
      'UPDATE marks_entries SET term_id = $1, class_section = $2, assessment_id = $3, subject_id = $4, student_list = $5 WHERE id = $6',
      [term_id, class_section, assessment_id, subject_id, student_list, id]
    );
    res.send('Marks entry updated');
  } catch (err) {
    console.error('Error updating marks entry:', err);
    res.status(500).send(err.message);
  }
});

app.delete('/marks-entries/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM marks_entries WHERE id = $1', [id]);
    res.send('Marks entry deleted');
  } catch (err) {
    console.error('Error deleting marks entry:', err);
    res.status(500).send(err.message);
  }
});

// Fetch all report card marks
app.get('/report-card-marks', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM report_card_marks ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching report card marks:', err);
    res.status(500).json({ message: 'Failed to fetch report card marks. Please try again.' });
  }
});

// Fetch all report sections
app.get('/report-sections', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM report_sections ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching report sections:', err);
    res.status(500).json({ message: 'Failed to fetch report sections. Please try again.' });
  }
});

// Fetch all designs
app.get('/designs', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM designs ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching designs:', err);
    res.status(500).json({ message: 'Failed to fetch designs. Please try again.' });
  }
});

// Fetch all exam types
app.get('/exam-types', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM exam_types ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching exam types:', err);
    res.status(500).json({ message: 'Failed to fetch exam types. Please try again.' });
  }
});

// Fetch all assessments
app.get('/assessments', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM assessments ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching assessments:', err);
    res.status(500).json({ message: 'Failed to fetch assessments. Please try again.' });
  }
});

// Add a new report card mark
app.post('/report-card-marks', async (req, res) => {
  const {
    report_section_id,
    design_id,
    display_name,
    column_type,
    display_position,
    display_percentage_separately,
    display_grades_separately,
    display_max_marks,
    generate_percentage_total_grade,
    generate_small_graph,
    small_graph_color,
    generate_big_graph,
    big_graph_name,
    display_on_green_sheet,
    display_on_report_card,
    result_sheet_order_no,
    result_sheet_header_name,
    class_section_ids,
    exam_type_ids,
    assessment_ids,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO report_card_marks (
        report_section_id, design_id, display_name, column_type, display_position,
        display_percentage_separately, display_grades_separately, display_max_marks,
        generate_percentage_total_grade, generate_small_graph, small_graph_color,
        generate_big_graph, big_graph_name, display_on_green_sheet, display_on_report_card,
        result_sheet_order_no, result_sheet_header_name, class_section_ids, exam_type_ids, assessment_ids
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
      RETURNING *`,
      [
        report_section_id, design_id, display_name, column_type, display_position,
        display_percentage_separately, display_grades_separately, display_max_marks,
        generate_percentage_total_grade, generate_small_graph, small_graph_color,
        generate_big_graph, big_graph_name, display_on_green_sheet, display_on_report_card,
        result_sheet_order_no, result_sheet_header_name, class_section_ids, exam_type_ids, assessment_ids
      ]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding report card mark:', err);
    res.status(500).json({ message: 'Failed to add report card mark. Please try again.' });
  }
});

// Edit a report card mark
app.put('/report-card-marks/:id', async (req, res) => {
  const { id } = req.params;
  const {
    report_section_id,
    design_id,
    display_name,
    column_type,
    display_position,
    display_percentage_separately,
    display_grades_separately,
    display_max_marks,
    generate_percentage_total_grade,
    generate_small_graph,
    small_graph_color,
    generate_big_graph,
    big_graph_name,
    display_on_green_sheet,
    display_on_report_card,
    result_sheet_order_no,
    result_sheet_header_name,
    class_section_ids,
    exam_type_ids,
    assessment_ids,
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE report_card_marks
      SET report_section_id = $1, design_id = $2, display_name = $3, column_type = $4, display_position = $5,
      display_percentage_separately = $6, display_grades_separately = $7, display_max_marks = $8,
      generate_percentage_total_grade = $9, generate_small_graph = $10, small_graph_color = $11,
      generate_big_graph = $12, big_graph_name = $13, display_on_green_sheet = $14, display_on_report_card = $15,
      result_sheet_order_no = $16, result_sheet_header_name = $17, class_section_ids = $18, exam_type_ids = $19, assessment_ids = $20
      WHERE id = $21 RETURNING *`,
      [
        report_section_id, design_id, display_name, column_type, display_position,
        display_percentage_separately, display_grades_separately, display_max_marks,
        generate_percentage_total_grade, generate_small_graph, small_graph_color,
        generate_big_graph, big_graph_name, display_on_green_sheet, display_on_report_card,
        result_sheet_order_no, result_sheet_header_name, class_section_ids, exam_type_ids, assessment_ids, id
      ]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error editing report card mark:', err);
    res.status(500).json({ message: 'Failed to edit report card mark. Please try again.' });
  }
});

// Delete a report card mark
app.delete('/report-card-marks/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query('DELETE FROM report_card_marks WHERE id = $1', [id]);
    res.status(200).json({ message: 'Report card mark deleted successfully' });
  } catch (err) {
    console.error('Error deleting report card mark:', err);
    res.status(500).json({ message: 'Failed to delete report card mark. Please try again.' });
  }
});

// Endpoint to fetch students
app.get('/students_fetch', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM student_list ORDER BY serial_no ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching students:', err);
    res.status(500).json({ message: 'Failed to fetch students. Please try again.' });
  }
});

// Node.js - Express route
app.post('/generate-rank', async (req, res) => {
  const { classSection, designId } = req.body;
  try {
    // Your logic to compute ranks
    const ranks = await computeRanks(classSection, designId);
    res.json(ranks);
  } catch (err) {
    console.error('Error generating ranks:', err);
    res.status(500).send('Failed to generate ranks.');
  }
});

app.get('/staffList', async (req, res) => {
  try {
    // Use ILIKE for case-insensitive comparison
    const result = await pool.query('SELECT * FROM staff_list WHERE designation ILIKE $1', ['teacher']);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching staff list:', err);
    res.status(500).json({ message: 'Failed to fetch staff list. Please try again.' });
  }
});

app.get('/timetable/:teacherId', async (req, res) => {
  const teacherId = req.params.teacherId;
  try {
    const result = await pool.query('SELECT * FROM timetable WHERE teacher_id = $1 ORDER BY day, start_time', [teacherId]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching timetable:', err);
    res.status(500).json({ message: 'Failed to fetch timetable. Please try again.' });
  }
});

app.post('/timetable', async (req, res) => {
  const { teacherId, day, startTime, endTime, subject, classSection } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO timetable (teacher_id, day, start_time, end_time, subject, class_section) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [teacherId, day, startTime, endTime, subject, classSection]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating timetable:', err);
    res.status(500).json({ message: 'Failed to create timetable. Please try again.' });
  }
});

app.put('/timetable/:id', async (req, res) => {
  const id = req.params.id;
  const { day, startTime, endTime, subject, classSection } = req.body;
  try {
    const result = await pool.query(
      'UPDATE timetable SET day = $1, start_time = $2, end_time = $3, subject = $4, class_section = $5 WHERE id = $6 RETURNING *',
      [day, startTime, endTime, subject, classSection, id]
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error updating timetable:', err);
    res.status(500).json({ message: 'Failed to update timetable. Please try again.' });
  }
});

app.delete('/timetable/:id', async (req, res) => {
  const id = req.params.id;
  try {
    await pool.query('DELETE FROM timetable WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting timetable:', err);
    res.status(500).json({ message: 'Failed to delete timetable. Please try again.' });
  }
});

app.get('/classSections', async (req, res) => {
  try {
    const result = await pool.query('SELECT DISTINCT class_section FROM student_list');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching class sections:', err);
    res.status(500).json({ message: 'Failed to fetch class sections. Please try again.' });
  }
});

app.get('/teacherTimetable/:email', async (req, res) => {
  const email = req.params.email;
  try {
    const result = await pool.query(
      `SELECT t.*, s.email
       FROM timetable t
       JOIN staff_list s ON t.teacher_id = s.id
       WHERE s.email = $1
       ORDER BY t.day, t.start_time`,
      [email]
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching timetable:', err);
    res.status(500).json({ message: 'Failed to fetch timetable. Please try again.' });
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
