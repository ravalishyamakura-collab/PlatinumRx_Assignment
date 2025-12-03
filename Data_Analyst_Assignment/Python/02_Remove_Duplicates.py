def unique_string(s: str) -> str:
    seen = set()
    result_chars = []
    for ch in s:
        if ch not in seen:
            seen.add(ch)
            result_chars.append(ch)
    return ''.join(result_chars)

# Examples
print(unique_string("banana"))   # "ban"
print(unique_string("abracadabra"))  # "abrcd"
