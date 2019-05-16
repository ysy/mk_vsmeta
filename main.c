#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

const int TAG_SHOW_TITLE = 0x12;
const int TAG_SHOW_TITLE2 = 0x1A;
const int TAG_EPISODE_TITLE = 0x22;
const int TAG_YEAR = 0x28;
const int TAG_EPISODE_RELEASE_DATE = 0x32;
const int TAG_EPISODE_LOCKED = 0x38;
const int TAG_CHAPTER_SUMMARY = 0x42;
const int TAG_EPISODE_META_JSON = 0x4A;
const int TAG_GROUP1 = 0x52;
const int TAG_CLASSIFICATION = 0x5A;
const int TAG_RATING = 0x60;

const int TAG_EPISODE_THUMB_DATA = 0x8a;
const int TAG_EPISODE_THUMB_MD5 = 0x92;

const int TAG_GROUP2 = 0x9a;

const int TAG1_CAST = 0x0A;
const int TAG1_DIRECTOR = 0x12;
const int TAG1_GENRE = 0x1A;
const int TAG1_WRITER = 0x22;

const int TAG2_SEASON = 0x08;
const int TAG2_EPISODE = 0x10;
const int TAG2_TV_SHOW_YEAR = 0x18;
const int TAG2_RELEASE_DATE_TV_SHOW = 0x22;
const int TAG2_LOCKED = 0x28;
const int TAG2_TVSHOW_SUMMARY = 0x32;
const int TAG2_POSTER_DATA = 0x3A;
const int TAG2_POSTER_MD5 = 0x42;
const int TAG2_TVSHOW_META_JSON = 0x4A;
const int TAG2_GROUP3 = 0x52;

const int TAG3_BACKDROP_DATA = 0x0a;
const int TAG3_BACKDROP_MD5 = 0x12;
const int TAG3_TIMESTAMP = 0x18;


typedef struct buffer
{
    unsigned char buf[1024];
    int offset;
} buffer_t;


void init_buffer(buffer_t  * buff)
{
    buff->offset = 0;
}

void dump_buffer(buffer_t * buff)
{
    int i = 0; 
    for (i=0; i<buff->offset; i++)
    {
         if (  i > 0 && !(i % 18) ) 
            printf("\n");
        printf("%02x ", buff->buf[i]);
       
    }
    printf("\n");
}

void write8(buffer_t * buff, unsigned char byte)
{
    buff->buf[buff->offset++] = byte;
}

void write_lv_int(buffer_t * buff,  int value)
{
    //unsigned long  v = *((unsigned int *) &value);
    unsigned int v  = (unsigned int)value;
    do {
        unsigned char data = v & 0x7f;
        v = v >>7;
        if (v != 0 )
            data |= 0x80;
        write8(buff, data);
    } while (v!=0) ; 
}


void write_tag(buffer_t * buff, unsigned char tag)
{
    write_lv_int(buff, tag);
}

void write_bytes(buffer_t * buff, unsigned char tag, 
                unsigned char * data, int len)
{
    write_tag(buff, tag);
    write_lv_int(buff, len);
    for (int i=0; i<len; i++)
        write8(buff, data[i]);
}

void write_raw_bytes(buffer_t * buff, unsigned char * data, int len)
{
    for (int i=0; i<len; i++)
        write8(buff, data[i]);
}

void write_string(buffer_t * buff, unsigned char tag, char * str)
{
    int len = strlen(str);
    
    write_bytes(buff, tag, (unsigned char *)str, len);
}

void write_buffer(buffer_t * buff, unsigned char tag, buffer_t * src_buff)
{
    write_bytes(buff, tag, src_buff->buf, src_buff->offset);
}
void write_int(buffer_t * buff, unsigned char tag, int val)
{
    write_tag(buff, tag);
    write_lv_int(buff, val);
}

static buffer_t main_buffer;
static buffer_t group2_buffer;


unsigned char rating_raw[] = {0x60, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01};

void usage()
{
    fprintf(stderr, "./mk_vsmeta -s 1 -e 1 -t show_title [-n episode_tile] filename\n");
}

int main(int argc, char * argv[]) 
{
    buffer_t * pbuf   = &main_buffer;
    buffer_t * pg2buf = &group2_buffer;
    int fd = 0;
    int c;
    int season = -1;
    int episode = -1;
    char * tvshow_title = NULL;
    char * episode_title = NULL;
    char * filename = NULL;

    while((c=getopt(argc, argv, "s:e:t:n:")) != -1) {
        switch(c)
        {
            case 's':
                season = atoi(optarg);
                break;
            case 'e':
                episode = atoi(optarg);
                break;
            case 't':
                tvshow_title = optarg;
                break;
            case 'n':
                episode_title = optarg;
                break;
        }
    }

    if (season < 0 || episode < 0 
            || tvshow_title == NULL || optind == argc) {
        usage();
        exit(-1);
    }

    filename = argv[optind];
    init_buffer(pbuf);
    init_buffer(pbuf);

    write8(pbuf, 0x08);
    write8(pbuf, 0x02); //magic header;

    write_string(pbuf, TAG_SHOW_TITLE, tvshow_title);
    write_string(pbuf, TAG_SHOW_TITLE2, tvshow_title);
    if (episode_title)
        write_string(pbuf, TAG_EPISODE_TITLE, episode_title);
    write_int(pbuf, TAG_YEAR, 0);
    write_int(pbuf, TAG_EPISODE_LOCKED, 1);
    write_string(pbuf, TAG_EPISODE_META_JSON, "null");
    write_int(pbuf, TAG_CLASSIFICATION, 0);
    write_raw_bytes(pbuf, rating_raw, sizeof(rating_raw));

    write_int(pg2buf, TAG2_SEASON, season);
    write_int(pg2buf, TAG2_EPISODE, episode);
    write_int(pg2buf, TAG2_TV_SHOW_YEAR, 0);
    write_int(pg2buf, TAG2_LOCKED, 1);
    write_string(pg2buf, TAG2_TVSHOW_META_JSON, "null");
    write_buffer(pbuf, TAG_GROUP2, pg2buf);

    //dump_buffer(pbuf);

    fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0660);
    if (fd < 0 ) {
        fprintf(stderr, "failed to open file: %s\n", filename);
        exit(-1);
    }

    write(fd, pbuf->buf, pbuf->offset);
    close(fd);
    return 0;
}
