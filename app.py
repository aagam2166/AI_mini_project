"""
Smart Home Energy Management System - CSP Backend
Optimizes appliance scheduling under power, time, and cost constraints
"""

from flask import Flask, request, jsonify, send_from_directory, abort
from flask_cors import CORS
from constraint import Problem, AllDifferentConstraint
import os
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

# Serve frontend files (index.html, style.css, script.js) from project root
@app.route('/', methods=['GET'])
def serve_index():
    try:
        return send_from_directory('.', 'index.html')
    except Exception:
        abort(404)


@app.route('/<path:filename>', methods=['GET'])
def serve_static(filename):
    # prevent exposing the server-side python files via this route
    if filename.endswith('.py') or filename == 'app.py':
        abort(404)
    try:
        return send_from_directory('.', filename)
    except Exception:
        abort(404)

class EnergyScheduler:
    """Constraint Satisfaction Problem solver for energy scheduling"""
    
    def __init__(self, appliances, constraints):
        self.appliances = appliances
        self.constraints = constraints
        self.max_power = constraints['max_power']
        self.max_cost = constraints['max_cost']
        self.electricity_rate = constraints['electricity_rate']
        # read optional extra constraints
        self.time_window_start = float(constraints.get('time_window_start', 0.0))
        self.time_window_end = float(constraints.get('time_window_end', 24.0))
        self.max_concurrent = int(constraints.get('max_concurrent', 1000))
        self.night_usage_allowed = bool(constraints.get('night_usage_allowed', True))

        # choose slot granularity based on problem size to keep domains manageable
        if len(self.appliances) > 6:
            # coarser slots (1 hour) for many appliances
            self.time_slots = self._generate_time_slots(interval=1.0)
        else:
            self.time_slots = self._generate_time_slots(interval=0.5)

        # Precompute feasible domains per appliance (respect deadlines and global time window)
        self.domains = self._compute_domains()
    
    def _generate_time_slots(self, interval=0.5):
        """Generate time slots for scheduling (30-minute intervals)"""
        slots = []
        current = 0.0
        while current < 24.0:
            slots.append(current)
            current += interval
        return slots

    def _compute_domains(self):
        domains = []
        for appliance in self.appliances:
            duration_hours = appliance['duration'] / 60.0
            deadline = min(float(appliance.get('deadline', 24)), 24.0)
            latest_start = max(0.0, deadline - duration_hours)
            # enforce global time window
            earliest_allowed = max(0.0, self.time_window_start)
            latest_allowed = min(24.0, self.time_window_end - duration_hours)
            domain = [s for s in self.time_slots if s <= latest_start and s >= earliest_allowed and s <= latest_allowed]
            domains.append(domain)
        return domains
    
    def _calculate_cost(self, power_w, duration_m):
        """Calculate energy cost for an appliance"""
        energy_kwh = (power_w * duration_m) / (60 * 1000)
        return energy_kwh * self.electricity_rate
    
    def _check_power_constraint(self, *start_times):
        """Check if power constraint is satisfied at any given time"""
        # For each time slot, check if total power doesn't exceed max_power
        for time_slot in self.time_slots:
            total_power = 0
            concurrent = 0
            # respect night usage setting: if not allowed, disallow slots between 0-6
            if not self.night_usage_allowed and 0.0 <= time_slot < 6.0:
                # if any appliance would run in night, constraint fails
                for i, appliance in enumerate(self.appliances):
                    start_time = start_times[i]
                    duration_hours = appliance['duration'] / 60.0
                    end_time = start_time + duration_hours
                    if start_time <= time_slot < end_time:
                        return False
                continue

            for i, appliance in enumerate(self.appliances):
                start_time = start_times[i]
                duration_hours = appliance['duration'] / 60.0
                end_time = start_time + duration_hours
                # Check if appliance is running at this time slot
                if start_time <= time_slot < end_time:
                    total_power += appliance['power']
                    concurrent += 1

            if total_power > self.max_power:
                return False
            if self.max_concurrent and concurrent > self.max_concurrent:
                return False
        
        return True
    
    def _check_deadline_constraint(self, *start_times):
        """Check if all appliances meet their deadlines"""
        for i, appliance in enumerate(self.appliances):
            start_time = start_times[i]
            duration_hours = appliance['duration'] / 60.0
            end_time = start_time + duration_hours
            
            if end_time > appliance['deadline']:
                return False
        
        return True
    
    def _check_cost_constraint(self, *start_times):
        """Check if total cost is within budget"""
        total_cost = 0
        for i, appliance in enumerate(self.appliances):
            cost = self._calculate_cost(appliance['power'], appliance['duration'])
            total_cost += cost
        
        return total_cost <= self.max_cost
    
    def _optimize_by_priority(self, solutions):
        """Sort solutions by priority (high priority first)"""
        def priority_score(solution):
            score = 0
            for i, appliance in enumerate(self.appliances):
                priority_map = {'low': 1, 'medium': 2, 'high': 3}
                priority_value = priority_map.get(appliance.get('priority', 'medium'), 2)
                score += priority_value
            return score
        
        return sorted(solutions, key=priority_score, reverse=True)
    
    def solve(self):
        """Solve the CSP and return optimal schedule"""
        try:
            # If any appliance has no feasible domain, fail early
            for d in self.domains:
                if not d:
                    return None

            # If problem is large use a greedy scheduler fallback
            if len(self.appliances) > 8:
                result = self._solve_greedy()
                if result is not None:
                    return result

            problem = Problem()

            # Order appliances by tightest deadline and priority to improve backtracking
            priority_map = {'low': 1, 'medium': 2, 'high': 3}
            indexed = list(enumerate(self.appliances))
            indexed.sort(key=lambda x: (float(x[1].get('deadline', 24)), -priority_map.get(x[1].get('priority', 'medium'), 2)))

            # Create variables using reduced domains
            var_names = []
            for idx, app in indexed:
                var = f'appliance_{idx}'
                domain = self.domains[idx]
                problem.addVariable(var, domain)
                var_names.append(var)

            # Add constraints
            # Power constraint
            problem.addConstraint(
                lambda *times: self._check_power_constraint(*times),
                var_names
            )

            # Deadline constraint (domains already respect deadlines but keep as safeguard)
            problem.addConstraint(
                lambda *times: self._check_deadline_constraint(*times),
                var_names
            )

            # Cost constraint
            problem.addConstraint(
                lambda *times: self._check_cost_constraint(*times),
                var_names
            )

            # Solve: request a single solution (faster and avoids huge memory use)
            best_solution = problem.getSolution()
            if not best_solution:
                # fallback to greedy attempt
                result = self._solve_greedy()
                if result is not None:
                    return result
                return None
            
            # Build schedule
            schedule = []
            total_cost = 0
            
            for i, appliance in enumerate(self.appliances):
                # best_solution keys might be appliance_{idx} where idx is original index
                start_time = best_solution.get(f'appliance_{i}')
                if start_time is None:
                    # find by searching keys
                    for k, v in best_solution.items():
                        if k.startswith('appliance_') and int(k.split('_')[1]) == i:
                            start_time = v
                            break
                duration_hours = appliance['duration'] / 60.0
                end_time = start_time + duration_hours
                
                cost = self._calculate_cost(appliance['power'], appliance['duration'])
                total_cost += cost
                
                schedule.append({
                    'name': appliance['name'],
                    'power': appliance['power'],
                    'duration': appliance['duration'],
                    'start_time': start_time,
                    'end_time': end_time,
                    'priority': appliance.get('priority', 'medium'),
                    'cost': cost
                })
            
            # Sort by start time
            schedule.sort(key=lambda x: x['start_time'])
            
            return {
                'schedule': schedule,
                'total_cost': total_cost,
                'total_power': sum(app['power'] for app in self.appliances),
                'feasible': True,
                'solver': 'csp'
            }
        
        except Exception as e:
            print(f"Error in solve: {str(e)}")
            return None

    def _solve_greedy(self):
        """A fast greedy scheduler: place appliances one-by-one by priority/deadline"""
        try:
            # Use integer-hour slots for greedy scheduling
            hours = list(range(24))
            power_hour = [0] * 24
            schedule = []

            # sort appliances: high priority first, then earlier deadline
            priority_map = {'low': 1, 'medium': 2, 'high': 3}
            apps = sorted(self.appliances, key=lambda a: (-priority_map.get(a.get('priority','medium'),2), float(a.get('deadline',24))))

            for app in apps:
                dur_h = max(1, int((app['duration'] + 59) // 60))
                deadline = min(24, float(app.get('deadline', 24)))
                placed = False
                # honor global time window
                earliest = int(max(0, self.time_window_start))
                latest_start = int(max(0, min(deadline - dur_h, self.time_window_end - dur_h)))
                for start in range(earliest, latest_start + 1):
                    can_place = True
                    for h in range(start, start + dur_h):
                        if h < 0 or h >= 24:
                            can_place = False
                            break
                        if power_hour[h] + app['power'] > self.max_power:
                            can_place = False
                            break
                        # check concurrent
                        # count current concurrent if this app would be added
                        if self.max_concurrent and power_hour[h] >= 0:
                            # compute number of appliances currently scheduled in that hour
                            # here we store only power_hour; compute concurrent by checking schedule
                            concurrent_count = 0
                            for s in schedule:
                                if int(s['start_time']) <= h < int(s['end_time']):
                                    concurrent_count += 1
                            if concurrent_count + 1 > self.max_concurrent:
                                can_place = False
                                break
                    if can_place:
                        for h in range(start, start + dur_h):
                            power_hour[h] += app['power']
                        schedule.append({
                            'name': app['name'],
                            'power': app['power'],
                            'duration': app['duration'],
                            'start_time': float(start),
                            'end_time': float(start + dur_h),
                            'priority': app.get('priority','medium'),
                            'cost': self._calculate_cost(app['power'], app['duration'])
                        })
                        placed = True
                        break
                if not placed:
                    return None

            schedule.sort(key=lambda x: x['start_time'])
            total_cost = sum(s['cost'] for s in schedule)
            return {'schedule': schedule, 'total_cost': total_cost, 'total_power': sum(app['power'] for app in self.appliances), 'feasible': True, 'solver': 'greedy'}
        except Exception as e:
            print('Greedy solver error:', e)
            return None


@app.route('/api/optimize', methods=['POST'])
def optimize_schedule():
    """API endpoint for optimization"""
    try:
        data = request.get_json()
        
        if not data or 'appliances' not in data or 'constraints' not in data:
            return jsonify({
                'success': False,
                'message': 'Missing appliances or constraints'
            }), 400
        
        appliances = data['appliances']
        constraints = data['constraints']
        electricity_rate = constraints['electricity_rate']
        
        # Validate input
        if not appliances:
            return jsonify({
                'success': False,
                'message': 'No appliances provided'
            }), 400
        
        # Create scheduler and solve
        scheduler = EnergyScheduler(appliances, constraints)
        result = scheduler.solve()
        
        if result is None:
            return jsonify({
                'success': False,
                'message': 'No feasible schedule found with current constraints. Try increasing max power, cost budget, or extending deadlines.'
            }), 200
        
        return jsonify({
            'success': True,
            'data': {
                'schedule': result['schedule'],
                'total_cost': result['total_cost'],
                'total_power': result['total_power'],
                'electricity_rate': electricity_rate,
                'feasible': result['feasible']
            }
        }), 200
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'Server is running'}), 200


if __name__ == '__main__':
    app.run(debug=True, port=5000, host='localhost')
