"""
Graphing utilities for synthetic data evaluation

This module provides utilities for parsing predicates and visualizing column usage
in synthetic data evaluation. It includes a class, `SinglingOutPlots`, with methods
for parsing predicates and generating bar plots for predicate column usage.

Usage:
    Import the module into your project:
        from utils import SinglingOutPlots

Classes:
    SinglingOutPlots: Handles parsing predicates and generating visualizations for 
    column usage statistics.

Author:
    Josiah Chua - 9.12.2024
"""

import re
import matplotlib.pyplot as plt
from collections import Counter


class SinglingOutPlots:
    """
    A utility class for parsing predicates and visualizing column usage statistics.

    Attributes:
        predicates (list): List of predicate strings to be parsed.
        columns (list): List of valid column names to validate against.
        processed_predicates (list): Parsed representation of predicates.
        columns_used (list): List of columns used in each predicate.
    """
    def __init__(self, predicates: list, columns: list):
        """
        Initialize the SinglingOutPlots instance with predicates and columns.

        Args:
            predicates (list): List of predicate strings.
            columns (list): List of valid column names.
        """
        self.predicates = predicates
        self.columns = columns
        self.processed_predicates, self.columns_used = self.parse_predicates()

    def parse_predicates(self):
        """
        Parse a list of predicate strings and extract column names, operators, and values.

        Returns:
            tuple: A tuple containing:
                - List of parsed predicates, where each predicate is a list of dictionaries
                  with keys 'column', 'operator', and 'value'.
                - List of columns used in each predicate, sorted alphabetically.
        """
        def parse_single_predicate(predicate):
            """
            Parse a single predicate string into expressions.

            Args:
                predicate (str): Predicate string to parse.

            Returns:
                tuple: Parsed expressions and list of columns used.
            """
            expressions = predicate.split('&')
            parsed_expressions = []
            predicate_columns = []
            for expr in expressions:
                expr = expr.strip()
                match = re.match(r'(\w+)\s*(==|>=|<=|>|<)\s*(\d+)', expr)
                if match:
                    column, operator, value = match.groups()
                    if column in self.columns:
                        parsed_expressions.append({
                            'column': column,
                            'operator': operator,
                            'value': int(value)
                        })
                        predicate_columns.append(column)
            return parsed_expressions, sorted(predicate_columns)

        parsed_predicates = []
        columns_used = []
        for predicate in self.predicates:
            parsed_predicate, predicate_columns = parse_single_predicate(predicate)
            parsed_predicates.append(parsed_predicate)
            columns_used.append(sorted(predicate_columns))

        return parsed_predicates, columns_used

    def plot_predicate_column_combi_count(self, title='Predicate Column Combinations Usage') -> None:
        """
        Plot a bar chart showing the usage of different column combinations across predicates.

        Args:
            title (str): Title of the plot. Defaults to 'Predicate Column Combinations Usage'.
        """
        predicate_column_strings = [','.join(cols) for cols in self.columns_used]
        column_combo_counts = Counter(predicate_column_strings)

        labels = list(column_combo_counts.keys())
        counts = list(column_combo_counts.values())

        plt.bar(labels, counts)
        plt.title(title)
        plt.xlabel('Column Combinations')
        plt.ylabel('Number of predicates')
        plt.xticks(rotation=45, ha='right')
        plt.tight_layout()
        plt.show()

    def plot_predicate_column_count(self, title='Predicate Individual Column Usage') -> None:
        """
        Plot a bar chart showing the total usage of columns across predicates.

        Args:
            title (str): Title of the plot. Defaults to 'Predicate Individual Column Usage'.
        """
        columns_used_total = [col for cols in self.columns_used for col in cols]
        column_counts = Counter(columns_used_total)

        labels = list(column_counts.keys())
        counts = list(column_counts.values())

        plt.bar(labels, counts)
        plt.title(title)
        plt.xlabel('Column')
        plt.ylabel('Number of predicates')
        plt.xticks(rotation=45, ha='right')
        plt.tight_layout()
        plt.show()
