# csp_solver.py



def generate_domains(appliances):
    domains = {}
    for appliance in appliances:
        start_min = appliance.earliest
        start_max = appliance.latest - appliance.duration
        domains[appliance.name] = list(range(start_min, start_max + 1))
    return domains


def calculate_cost(schedule, appliances, prices):
    total_cost = 0
    for appliance in appliances:
        start_time = schedule[appliance.name]
        for h in range(start_time, start_time + appliance.duration):
            total_cost += appliance.power * prices[h]
    return total_cost


def calculate_par(schedule, appliances):
    hourly_load = [0] * 24

    for appliance in appliances:
        start = schedule[appliance.name]
        for h in range(start, start + appliance.duration):
            hourly_load[h] += appliance.power

    peak = max(hourly_load)
    average = sum(hourly_load) / 24

    if average == 0:
        return 0

    return peak / average


def greedy_schedule(appliances, prices):
    schedule = {}

    for appliance in appliances:
        best_start = None
        best_cost = float("inf")

        start_min = appliance.earliest
        start_max = appliance.latest - appliance.duration

        for start in range(start_min, start_max + 1):
            cost = 0
            for h in range(start, start + appliance.duration):
                cost += appliance.power * prices[h]

            if cost < best_cost:
                best_cost = cost
                best_start = start

        schedule[appliance.name] = best_start

    return schedule


def solve_csp(appliances, prices, max_par=None, alpha=1.0, beta=1.0):
    domains = generate_domains(appliances)

    best_schedule = None
    best_cost = float("inf")
    best_score = float("inf")

    def backtrack(index, current_schedule):
        nonlocal best_schedule, best_cost, best_score

        # If all appliances assigned
        if index == len(appliances):
            cost = calculate_cost(current_schedule, appliances, prices)
            par = calculate_par(current_schedule, appliances)

            # --- CONSTRAINED MODE ---
            if max_par is not None:
                if par <= max_par:
                    if cost < best_cost:
                        best_cost = cost
                        best_schedule = current_schedule.copy()

            # --- WEIGHTED MODE ---
            else:
                score = alpha * cost + beta * par
                if score < best_score:
                    best_score = score
                    best_schedule = current_schedule.copy()

            return

        appliance = appliances[index]

        for start_time in domains[appliance.name]:
            current_schedule[appliance.name] = start_time
            backtrack(index + 1, current_schedule)
            del current_schedule[appliance.name]

    backtrack(0, {})

    return best_schedule