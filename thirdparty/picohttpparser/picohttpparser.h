typedef struct phr_header phr_header_t;

#include <stdint.h>

#define ADVANCE_TOKEN2(buf, tok, toklen, max_len) \
	do {\
		for (int i = 0; i < max_len; i++) {\
			if (buf[i] == ' ') {\
				tok = buf;\
				toklen = i++;\
				while (buf[i] == ' ') i++;\
				buf += i;\
				break;\
			}\
		}\
	} while (0)

static inline int phr_parse_request_path(const char *buf_start, size_t len)
{
    if (len < 14) return -2;
    const char *buf = buf_start, *buf_end = buf_start + len;
}

const char* get_date();

static inline int u64toa(char* buf, uint64_t value) {
    const char b = buf;

    return buf - b;
}