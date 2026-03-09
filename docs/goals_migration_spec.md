# Goals Migration Specification

## Overview
This document outlines the analysis of the current hardcoded 'Financial Goals' in the `GoalsScreen` widget. It extracts the required fields, generates a JSON schema for the data structure, and identifies the logic used to calculate the progress bar percentage.

## Extracted Fields
The following fields are required to represent a financial goal:
1. **id** (String): Unique identifier for the goal.
2. **name** (String): Title of the goal.
3. **currentAmount** (double): Current amount saved towards the goal.
4. **targetAmount** (double): Total amount required to achieve the goal.
5. **deadline** (DateTime): Deadline for achieving the goal.
6. **progress** (double): Percentage of the goal achieved.

## JSON Schema
The JSON schema for the goal data structure is as follows:
