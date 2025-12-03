def human_readable_minutes(total_minutes: int) -> str:
    if total_minutes < 0:
        raise ValueError("minutes must be non-negative")
    hours = total_minutes // 60
    minutes = total_minutes % 60
    parts = []
    if hours > 0:
        parts.append(f"{hours} hr" + ("s" if hours != 1 else ""))
    if minutes > 0 or hours == 0:
        parts.append(f"{minutes} minute" + ("s" if minutes != 1 else ""))
    return " ".join(parts)

# Examples
print(human_readable_minutes(130))  # "2 hrs 10 minutes"
print(human_readable_minutes(110))  # "1 hr 50 minutes"

